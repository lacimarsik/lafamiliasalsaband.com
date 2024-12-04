\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Vivir Mi Vida"
  instrument = "trombone"
  composer = "by Marc Anthony"
  arranger = "arr. Ladislav Maršík"
  opus = "version 17.7.2024"
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

Trombone = \new Voice
\transpose c g, % Ivar transposition c g,
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Trombone" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

\clef bass
  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 190
  
  s1*0 ^\markup { "Voy A Reír" }
     \inst "A1"
  R1*16 
  
    s1*0 ^\markup { "Voy A Reír Salsa" }
   \inst "A2"
   es'4 \accent \bendAfter #-8 \f r2. | \break
   R1*7 
r4. es,8 ~ es d es4 ~ |
 es2 r2 |
  r4. es8 ~ es d es4 ~ |
  es2 r2 |
  r4. g8 ~ g f g4 ~ |
  g2 r2 |
  r4. f8 ~ f es f4 ~ |
  f2 d2 | \break
  
   s1*0 ^\markup { "Verso 1" }
   \inst "B"
    \segno
   es4 -- r2. |
     R1*15
     
   s1*0 ^\markup { "Y Para Qué" }
   \inst "C"
  
  r4. c8 ~ c bes c4 ~ |
  c2 r2 |
  r4. c8 ~ c bes c4 ~ |
  c2 r2 |
  r4. es8 ~ es d es4 ~ |
  es2 r2 |
    r4. d8 ~ d c d4 ~ |
  d2 r2 | \break
  
  r2 g'4 \accent \f  r |
    r2 g4 \accent  r |
      r2 as4 \accent  r |
  R1*3
  d,4 \accent r d \accent r|
   \tuplet 3/2 { f4 \accent f \accent f \accent } f4 \accent  r  |
  
    s1*0 ^\markup { "Voy A Reír     to " \musicglyph "scripts.coda" }
     \inst "A3"
  R1*16 \break
  
       s1*0 ^\markup { "Interlude" }
     \inst "D"
  
  r2. g,,4 \f |
  c2 es |
  es4 r r as, |
  c2 es |
  es4 r r g, |
  bes2 es |
  d4 r r d |
  \tuplet 3/2 { d2 c bes }
  c'2 ^\markup { "Trombones" } d |
  es g, |
  as es' ~ |
  es r |
  es f |
  g es |
  bes f'   ^\markup { "Dal " \musicglyph "scripts.segno" " al " \musicglyph "scripts.coda" } |  \break
  
      s1*0 ^\markup { "Interlude 2" }
     \inst "E"
  
    \mark \markup { \musicglyph "scripts.coda" }
    
    \repeat volta 2 {
    r8 c4 \mf c8 es4 es4 |
    es2. r4 |
    r8 c4 \mf c8 es4 es4 |
    es2. r4 |
            r8 bes4 bes8 d4 d4 |
    g2. r4 |
    }
    \alternative { 
   {   
          r8 d4 d8 f4 f4 |
    f2. r4 |
}
    {
              d4 \f \accent r d \accent  r |
    \tuplet 3/2 { f4 \accent f \accent f \accent } f4 \accent r \break
    }
    }
    
        s1*0 ^\markup { "Voy A Reír" }
     \inst "A4"
  R1*16 \break
  
        s1*0 ^\markup { "Interlude 3" }
     \inst "F"
  \repeat volta 2 {
  r4. g,8 \f ~ g4 bes ~ |
  bes8 c4. g2 |
    r4. as8 ~ as4 bes ~ |
  bes8 c4. as2 |
      r4. g8 ~ g4 bes ~ |
  bes8 bes4. g2 |
      r4. f8 ~ f4 bes ~ |
  bes8 bes4. g2 |
  }
    
  s1*0 ^\markup { "Voy A Reír" }
     \inst "A5"
  R1*24 
  
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \Trombone
  }
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
}


\paper {
  system-system-spacing =
  #'((basic-distance . 14)
     (minimum-distance . 10)
     (padding . 1)
     (stretchability . 60))
  between-system-padding = #2
  bottom-margin = 5\mm

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