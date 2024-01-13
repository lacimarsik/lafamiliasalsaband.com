\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Would I Lie"
  instrument = "bass"
  composer = "by Cubaneros"
  arranger = "arr. Ladislav Maršík"
  opus = "version 7.9.2022"
  copyright = "© La Familia Salsa Band"
}

inst =
#(define-music-function
  (string)
  (string?)
  #{ <>^\markup \abs-fontsize #16 \bold \box #string #})

makePercent = #(define-music-function (note) (ly:music?)
                 (make-music 'PercentEvent 'length (ly:music-length note)))

#(define (test-stencil grob text)
   (let* ((orig (ly:grob-original grob))
          (siblings (ly:spanner-broken-into orig)) ; have we been split?
          (refp (ly:grob-system grob))
          (left-bound (ly:spanner-bound grob LEFT))
          (right-bound (ly:spanner-bound grob RIGHT))
          (elts-L (ly:grob-array->list (ly:grob-object left-bound 'elements)))
          (elts-R (ly:grob-array->list (ly:grob-object right-bound 'elements)))
          (break-alignment-L
           (filter
            (lambda (elt) (grob::has-interface elt 'break-alignment-interface))
            elts-L))
          (break-alignment-R
           (filter
            (lambda (elt) (grob::has-interface elt 'break-alignment-interface))
            elts-R))
          (break-alignment-L-ext (ly:grob-extent (car break-alignment-L) refp X))
          (break-alignment-R-ext (ly:grob-extent (car break-alignment-R) refp X))
          (num
           (markup text))
          (num
           (if (or (null? siblings)
                   (eq? grob (car siblings)))
               num
               (make-parenthesize-markup num)))
          (num (grob-interpret-markup grob num))
          (num-stil-ext-X (ly:stencil-extent num X))
          (num-stil-ext-Y (ly:stencil-extent num Y))
          (num (ly:stencil-aligned-to num X CENTER))
          (num
           (ly:stencil-translate-axis
            num
            (+ (interval-length break-alignment-L-ext)
               (* 0.5
                  (- (car break-alignment-R-ext)
                     (cdr break-alignment-L-ext))))
            X))
          (bracket-L
           (markup
            #:path
            0.1 ; line-thickness
            `((moveto 0.5 ,(* 0.5 (interval-length num-stil-ext-Y)))
              (lineto ,(* 0.5
                          (- (car break-alignment-R-ext)
                             (cdr break-alignment-L-ext)
                             (interval-length num-stil-ext-X)))
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (closepath)
              (rlineto 0.0
                       ,(if (or (null? siblings) (eq? grob (car siblings)))
                            -1.0 0.0)))))
          (bracket-R
           (markup
            #:path
            0.1
            `((moveto ,(* 0.5
                          (- (car break-alignment-R-ext)
                             (cdr break-alignment-L-ext)
                             (interval-length num-stil-ext-X)))
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (lineto 0.5
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (closepath)
              (rlineto 0.0
                       ,(if (or (null? siblings) (eq? grob (last siblings)))
                            -1.0 0.0)))))
          (bracket-L (grob-interpret-markup grob bracket-L))
          (bracket-R (grob-interpret-markup grob bracket-R))
          (num (ly:stencil-combine-at-edge num X LEFT bracket-L 0.4))
          (num (ly:stencil-combine-at-edge num X RIGHT bracket-R 0.4)))
     num))

#(define-public (Measure_attached_spanner_engraver context)
   (let ((span '())
         (finished '())
         (event-start '())
         (event-stop '()))
     (make-engraver
      (listeners ((measure-counter-event engraver event)
                  (if (= START (ly:event-property event 'span-direction))
                      (set! event-start event)
                      (set! event-stop event))))
      ((process-music trans)
       (if (ly:stream-event? event-stop)
           (if (null? span)
               (ly:warning "You're trying to end a measure-attached spanner but you haven't started one.")
               (begin (set! finished span)
                 (ly:engraver-announce-end-grob trans finished event-start)
                 (set! span '())
                 (set! event-stop '()))))
       (if (ly:stream-event? event-start)
           (begin (set! span (ly:engraver-make-grob trans 'MeasureCounter event-start))
             (set! event-start '()))))
      ((stop-translation-timestep trans)
       (if (and (ly:spanner? span)
                (null? (ly:spanner-bound span LEFT))
                (moment<=? (ly:context-property context 'measurePosition) ZERO-MOMENT))
           (ly:spanner-set-bound! span LEFT
                                  (ly:context-property context 'currentCommandColumn)))
       (if (and (ly:spanner? finished)
                (moment<=? (ly:context-property context 'measurePosition) ZERO-MOMENT))
           (begin
            (if (null? (ly:spanner-bound finished RIGHT))
                (ly:spanner-set-bound! finished RIGHT
                                       (ly:context-property context 'currentCommandColumn)))
            (set! finished '())
            (set! event-start '())
            (set! event-stop '()))))
      ((finalize trans)
       (if (ly:spanner? finished)
           (begin
            (if (null? (ly:spanner-bound finished RIGHT))
                (set! (ly:spanner-bound finished RIGHT)
                      (ly:context-property context 'currentCommandColumn)))
            (set! finished '())))
       (if (ly:spanner? span)
           (begin
            (ly:warning "I think there's a dangling measure-attached spanner :-(")
            (ly:grob-suicide! span)
            (set! span '())))))))

\layout {
  \context {
    \Staff
    \consists #Measure_attached_spanner_engraver
    \override MeasureCounter.font-encoding = #'latin1
    \override MeasureCounter.font-size = 0
    \override MeasureCounter.outside-staff-padding = 2
    \override MeasureCounter.outside-staff-horizontal-padding = #0
  }
}

repeatBracket = #(define-music-function
                  (parser location N note)
                  (number? ly:music?)
                  #{
                    \override Staff.MeasureCounter.stencil =
                    #(lambda (grob) (test-stencil grob #{ #(string-append(number->string N) "x") #} ))
                    \startMeasureCount
                    \repeat volta #N { $note }
                    \stopMeasureCount
                  #}
                  )

Bass = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Bass" }
  }
  \set Staff.midiInstrument = "acoustic bass"
  \set Staff.midiMaximumVolume = #1.5

  \clef bass
  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
  \set Score.skipBars = ##t R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es } | 
  g4 r4 es4 \glissando c4 |
  
  \inst "A"
  \repeat volta 2 {
    as4. ^\markup { "Chorus" } es'4. as4 ~ |
    as4. es4. as,4 |
    \ottava #-1
    f4. c'4. f4 ~ |
    f4. f,4. c4 |
    c4. g'4. c4 ~ |
    c4. c,4. g'4 |
  }
  \alternative {{
    es4. bes'4. es4 ~ |
    es4. bes4. es,8 es |
                }{      
                  es4. bes'4. es4 ~ |
                  es4. es,4. f4 ~ |
                }
  }
  
  \inst "B"
  f1 ^\markup { "Verse 1" }  ~ |
  f |
  R1 |
  
  \ottava #0
  r4 b8 ( c4 ) r8 f4 ~ |
  f1 |
  
  \set Score.skipBars = ##t R1*6
  
  r4 b,8 ( c4 ) r8 f4 ~ |
  f1 |
  \set Score.skipBars = ##t R1*3
  \repeat percent 7 { \makePercent s1 }
  \makePercent s2 as8 -> as -> r4 |
  
  \inst "C"
  s1*0 ^\markup { "Chorus" }
  \repeat volta 7 { \repeatBracket 7 { \makePercent s1*2 } }
  \makePercent s1 |
    \makePercent s2. f4 ~ |
  
  \inst "D"
  f1 ^\markup { "Verse 2" }  ~ |
  f |
  R1 |
  
  \ottava #0
  r4 b,8 ( c4 ) r8 f4 ~ |
  f1 |
  
  \set Score.skipBars = ##t R1*6
  
  r4 b,8 ( c4 ) r8 f4 ~ |
  f1 |  
  \set Score.skipBars = ##t R1*3
  
  \inst "E"
  bes,4 ^\markup { "Swing!" } c d f |
  bes c d g, |
  f a bes b | \break
  c f, fis g |
  d c b g |
  fis f d as' ~ |
  as1 ~ |
  as2 \bendAfter #-5 r4 as \accent |
  
  s1*0 ^\markup { "Chorus" }
  \repeat volta 8 { \repeatBracket 8 { \makePercent s1*2 } }
  
  \inst "F"
    s1*0 ^\markup { "Trombone Solo" }
  \repeat volta 8 { \repeatBracket 8 { \makePercent s1*2 } }
  f'4 ^\markup { "Would I lie to you" } -> r2. |
  \ottava #0
  
  \set Score.skipBars = ##t R1*15
  
  \inst "G"
  s1*0 ^\markup { "Te digo" }
  bes,4 bes bes bes | bes4 bes bes bes |
  a a a a | a a a g |
  g g g g | g g g as |
  as as as as | as as as as
  
  as8 -> as -> r4 as8 -> as -> r4 |
  \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. |
  
    s1*0 ^\markup { "Chorus" }
  \repeat volta 4 { \repeatBracket 4 { \makePercent s1*2 } }
  
  \repeat percent 5 { \makePercent s1 }
  \makePercent s2. f4 -> ~ |
  f1 ~ |
  f2 es'4 \glissando f, |
  
  \inst "H"
  \ottava #-1
  \repeat volta 2 {
    as,4. ^\markup { "Montuno - Petas" } es'4. as4 ~ |
    as4. as,8 ~ as es' f fis |
    g4. d4. g,4 ~ |
    g4. g8 ~ g c c, c |
    c4. g'4. c4 ~ |
    c4. c,8 ~ c g' f f |
    f4. c'4. f4 ~ |
    f4. c8 ~ c f, as as |
  }
  
  \inst "I"
  s1*0 ^\markup { "Coro Pregón" }
  \repeat volta 4 {
    \repeatBracket 4 {
      as4. es'4. as4 ~ |
      as4. es4. f4 |
      g4. d4. r4 |
      g,4. d'4. r4 |
      c,4. d4. r4 |
      es4. e4. r4 |
      f4. c'4. f4 ~ |
      f4. c8 ~ c f, as as |
    }
  }
  
  as1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  
  as'1 ^\markup { "A Capella" }  ~ |
  as1 |
  g1 ~ |
  g1 |
  c,1 ~ |
  c1 |
  f,1 ~ |
  f1 |
  
  \label #'lastPage
  \bar "|."  
}

Chords = \chords {
  R1*16
  \repeat volta 2 {
    as1 | as | f:m | f:m |
    c:m | c:m
  }
  \alternative {
    {
      es | es
    }
    {      
      es | es
    }
  }
  
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  bes | bes | f | f |
  g | g | as | as |
  
  \repeat volta 7 {\makePercent s1 | \makePercent s1 }
  | es | es |
  
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  bes | bes | f | f |
  g | g | as | as |
  
  \repeat volta 8 { \makePercent s1 | \makePercent s1 } 
  
  \repeat volta 8 { \makePercent s1 | \makePercent s1 } 
  
  f | r1*7 | r1*8
  
  bes1 | bes | f/a | f/a |
  g | g | as | as |
  as | as |
  
  \repeat volta 4 { \makePercent s1 | \makePercent s1 } 
  
  as | as | f:m | f:m |
  c:m | c:m | f | f |
  
  \repeat volta 2 {
    as | as | g | g |
    c:m | c:m | f | f |
  }
  \repeat volta 4 {
    as | as | g | g |
    c:m | c:m | f | f |  
  }
  as | r1*7 
  as1 | as | g | g |
  c:m | c:m | f | f |
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Bass
    }
  >>
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
}

\paper {
  system-system-spacing =
  #'((basic-distance . 15)
     (minimum-distance . 10)
     (padding . 1)
     (stretchability . 60))
  between-system-padding = #2
  bottom-margin = 5\mm

  print-page-number = ##t
  print-first-page-number = ##t
  oddHeaderMarkup = \markup \fill-line { " " }
  evenHeaderMarkup = \markup \fill-line { " " }
  oddFooterMarkup = \markup {
    \fill-line {
      \bold \fontsize #2
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }

      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }
    }
  }
  evenFooterMarkup = \markup {
    \fill-line {
      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }

      \bold \fontsize #2
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
    }
  }
}