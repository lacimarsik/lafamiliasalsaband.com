\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "#26 Señorita"
  instrument = "trumpet"
  composer = "by Shawn Mendes feat. Camila Cabello"
  arranger = "arr. Ladislav Maršík"
  opus = "version 3.4.2024"
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

Trumpet = \new Voice
\transpose c d
\relative c'' {
  \set Staff.instrumentName = \markup {
    \center-align { "Tr. in Bb" }
  }
  \set Staff.midiInstrument = "trumpet"
  \set Staff.midiMaximumVolume = #1.0

  \key g \minor
  \time 4/4
  \tempo "Slow Bachata" 4 = 120
  
  s1*0 ^\markup { "Piano Intro" }
  \inst "A"
  R1*7 
    
  r2 bes8 -> \f ( a g a ) |
  
    s1*0 ^\markup { "Brass Intro" }
  \inst "B"
  bes4 -> g -- d -- bes'8 ( a ) |
  r f -- ~ f r bes8 ( a g a ) |
  bes4 -- f -- d -- bes'8 ( a ) |
  r f -- ~ f a ( bes8 a g f ) |
  \tuplet 3/2 { es4 -- bes' -- bes -- } bes -- r |
  \tuplet 3/2 { es,4 -- bes' -- bes -- } bes -- r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) bes8 -> ( a g a ) | \break
  bes4 -- g -- d -- bes'8 ( a ) |
  r f -- ~ f a ( bes8 a g a ) |
  bes4 -- f -- d -- bes'8 ( a ) |
  r f -- ~ f r bes8 ( a g f ) |
  \tuplet 3/2 { es4 -- bes' -- bes -- } bes -- r |
  \tuplet 3/2 { es,4 -- bes' -- bes -- } bes -- r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) \tuplet 3/2 { a4 -- g4 -- f4 -- } |
  g2 -- r2 |
  
    s1*0 ^\markup { "Chorus 1" }
  \inst "C1"
  R1*7 
  
    s1*0 ^\markup { "Verse 1" }
  \inst "D1"
  
  
    R1*16 
    
    s1*0 ^\markup { "Chorus 2" }
  \inst "C2"
  R1*7 
   r2 bes8 -> \mf ( a g a ) |
  bes4 -> g -- d -- bes'8 ( a ) |
  r f -- ~ f r bes8 ( a g a ) |
  bes4 -- f -- d -- bes'8 ( a ) |
  r f -- ~ f a ( bes8 a g f ) |
  \tuplet 3/2 { es4 -- bes' -- bes -- } bes -- r |
  \tuplet 3/2 { es,4 -- bes' -- bes -- } bes -- r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) a8 -- g  --  r f --
  g4 -> r2. |
  
      s1*0 ^\markup { "Verse 2" }
  \inst "D2"
      R1*7
      
      
      d2 \< \mf r2 \! |
            d2 \< r2 \! |
                        d2 \< r2 \! |
                        a4 -- a4 -- r2 | 
     s1*0 ^\markup { "Chorus 3 - Trombone solo base" }
  \inst "C3"
  R1*7
   r2 bes'8 -> \mf ( a g a ) | \break
  bes4 -> ^\markup { "tutti" } g -- d -- bes'8 ( a ) |
  r f -- ~ f r bes8 ( a g a ) |
  bes4 -- f -- d -- bes'8 ( a ) |
  r f -- ~ f a ( bes8 a g f ) |
  \tuplet 3/2 { es4 -- bes' -- bes -- } bes -- r |
  \tuplet 3/2 { es,4 -- bes' -- bes -- } bes -- r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) a8 -- g  --  r f -- | \break
  s1*0 ^\markup { "Vocals" }
  \inst "E"
  g1 |
  r2 f2 |
  f1 |
  r2 es2 |
  d2. d8 es  |
  \tuplet 3/2 { f4 g f es d c } |
  c2 r2 |
  c2 r2 | \break
    \inst "F"
  R1*5 ^\markup { "Solo sax" }
  r2. r8 a' -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) a8 -- g  --  r f --
  g4 -> r2. |
    R1*5 ^\markup { "Solo trombone" }
  r2. r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) a8 -- g  --  r f --
  g4 -> r2. |
      R1*5 ^\markup { "Solo trumpet" }
  r2. r8 a -> ~ |
  a ( bes ) a ( bes ) a ( f ) r a -> ~ |
  a ( bes ) a ( bes ) a8 -- g  --  r f --
  g4 -> r2. |

  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \Trumpet
  }
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
  \midi { }
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