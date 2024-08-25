\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "#20 Hello"
  instrument = "tenor sax"
  composer = "by Mandinga"
  arranger = "arr. Ladislav Maršík"
  opus = "version 16.11.2022"
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

TenorSax = \new Voice
\transpose c d'
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "T. Sax in Bb" }
  }
  \set Staff.midiInstrument = "tenor sax"
  \set Staff.midiMaximumVolume = #0.9

  \clef treble
  \key f \minor
  \time 4/4
  \key f \minor
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190
  
   s1*0 ^\markup { "Intro PIano" }
 R1*8 
    s1*0 ^\markup { "Verse 1" }
 \inst "A"
 R1*14
 bes4 -- \mp bes -- bes -- c -- ~ \< |
 c1 |
 R1 \mf \! |
 
  s1*0 ^\markup { "Verse 2" }
   \inst "B"
 R1 |
 r8 es -. \mp r bes -- ~ bes2 |
  r2 c8 ( es f4 ~ |
  f1 ) |
  R1*5
  r2 es'8 \mp c -. r bes ~ |
  bes2. as8 c ~ |
  c2 ~ c8 as c bes ~ |
  bes2. as8 g ~ |
  g4. es8 ~ es4. c8 ~ |
  c1 |
  R1 |  \break
  
  \segno 
    s1*0 ^\markup { "Bridge" }
   \inst "C"
  r2 r8 f -- \mp \< r g -- |
  r es -- ~ es2 c'4 \mf -- ~ |
  c2 r8 es, -. r es -. \bendAfter #-4 |
  R1 |
  des2. \mp -- c4 -- ~ |
  c2 bes -- ~ |
  bes1 |
  \breathe as'2 \mf g4 -- r | \break
  
   s1*0 ^\markup { "Chorus Part 1" }
   \inst "D"
  c,4 \p \< -- c -- c -- c -- |
  des -- des -- des -- es \f -> |
  r8 f -. \mp r as -. r bes -. r bes -- ~ |
  bes4. as8 -. r bes8 c4 -- |
  R1*2 
  r4 as8 \mf g -. r es -. r4 |
  c'8 -> \f es ~ es2. |
  R1 | \break
  R1 |
  r2 r4. c16 \mp des |
  c4 -- des -- es -- bes -- \< ~ | 
  bes1 |
  R1 \mf |
  r4 as8 \mp f -. r es -. r4 |
  c8 ( des c4 ) r8 as' ( as g ) |
  r c \mf \< ( bes g bes c ) r c | \break
  
  s1*0 ^\markup { "Chorus Part 2" }
  \inst "E"
  c4 -> \f r2. |
  R1 |
  r4. c,8 \mf -. r es -. r c -. |
  es4 -- f -- r2 |
  R1*2 
  r8 bes, -. r c -. r es -. r c -. |
  es4 -- f -- r2 |
  R1*7
  r4. \coda ^\markup { "to coda" } es8 -. \mf r f -. r as -> ~ | \break
  
    s1*0 ^\markup { "Puente" }
  \inst "F"
  as4 f8 -. r8 r f -. r as -. |
  r f -. r es -. r f -. r as ->  ~ |
  as4 f8 -. r r f -. \< r bes \f -> |
  r as -. r g -. r es -. r es -> ~ |
  es4 f8 r r es \> ( c es ) ~ |
  es4 c -. bes -. as -. \mp |
  es' -. as8 -> g -. r es -. r c -. |
  es1 -> \> | \break
  
  s1*0 ^\markup { "Verse 3" }
  \inst "G"
  R1*3 \! 
  r2 c8 \mf ( des c es ) ~ |
  es4 bes'8 ( as ) ~ as4 as8 ( g ) ~ |
  g2. es8 ( f ) ~ |
  f1 |
  r4 c8 \f -> c -> c -> c -> r4 |
  r2 r8 es \mf ( c bes' ) |
  r as -- ~ as2. |
  bes2. -- c8 ( as ) ~ |
  as1 |
  R1*4 ^\markup { "Dal " \musicglyph "scripts.segno" " al " \musicglyph "scripts.coda" }
  \break
  
    \mark \markup { \musicglyph "scripts.coda" }
    s1*0 ^\markup { "Coda - Mambo" }
  \inst "H"
  R1 | 
  \repeat volta 3 {
  c8 \mf -- c --  r4 des8 -- des -- r4 |
  r8 c -- r4 des8 -- des -- r4 |
  c8  -- c --  r4 des8 -- c -- r4 |
    r8 bes -- r4 c8 -- bes -- r4 |
  c8 -- c --  r4 des8 -- des -- r4 |
  r8 c -- r4 des8 -- des -- r4 |
  c8  -- c --  r4 des8 -- des -- r4 |
   \alternative {
     \volta 1,2 {
        r8 bes -- r4 c8 -- bes -- r4 |
     }
     \volta 3 {
       r8 c \f ( bes g bes c -. ) r c -- |
     }
   }
   c4 -> \ff r2. |
   
  }
  
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \TenorSax
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