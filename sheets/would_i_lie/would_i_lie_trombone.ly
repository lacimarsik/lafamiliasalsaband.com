\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Would I Lie"
  instrument = "trombone"
  composer = "by Luis Enrique"
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

Trombone = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Trombone" }
  }
  \set Staff.midiInstrument = "trombone"
  \set Staff.midiMaximumVolume = #1.0

  \clef bass
  \key c \minor
  \time 4/4
  \tempo "Allegro" 4 = 180
  
  \set Score.skipBars = ##t R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es } | 
  g r8 es8 es4 r | \break
  
  \inst "A"
  as,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
  as2 r |
  f,4 r8 f'4 r8 as4 ~ |
  as2 r |
  c,4 r8 es8 es r g4 ~ |
  g2 r |
  bes,4 r8 es8 es r g4 ~ |
  g2 r | \break
  
  es4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 f8 f r as4 ~ |
  as2 r |
  c,4 r8 g'8 g r c4 ~ |
  c4 d2 bes4 ~ |
  bes2 r4 g'4 ~ |
  g2 r2 | \break
  
  \inst "B"
  R1*11 ^\markup { "Verse 1" } 
  
  g,4 g4. r8 f4 ~ |
  f1 |
  R1 |
  R1 |
  
  r4 f,2. \> |
  R1*2 \! |
  r4 c'8 -. r r bes -. r4 |
  c8 -. r d8 -. r c' -> r -. d4 ~ -> \sp \< |
  d1 ~ |
  d2 \! r4 es4 ~ |
  es1 |  
  r2 bes'8 -> bes -> r4 | \break
  
  \inst "C"
  as,,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
  as2 r |
  f,4 r8 f'4 r8 as4 ~ |
  as2 r |
  c,4 r8 es8 es r g4 ~ |
  g2 r |
  bes,4 r8 es8 es r g4 ~ |
  g2 r | \break
  
  es4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 f8 f r as4 ~ |
  as2 r |
  c,4 r8 g'8 g r c4 ~ |
  c4 d2 bes4 ~ |
  bes2 r4 g'4 ~ |
  g2 r2 | \break
  
  \inst "D"
  R1*11 ^\markup { "Verse 2" } 
  
  g,4 g4. r8 f4 ~ |
  f1 |
  \set Score.skipBars = ##t R1*3
  \inst "E"
  r8 ^\markup { "Swing!" } bes \mf -. r4 bes -> r8 bes -. |
  R1 |
  r4 f8 -. r r f -. r4 |
  f8 -. r fis8 -. r r4 d'8 -. r |
  r8 d -. r4 d -> r8 d -. |
  r2. c4 ~ -> \sp \< |
  c1 ~ |  
  c2 \! r4 as, -> | \break

  as4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
  as2 r |
  f,4 r8 f'4 r8 as4 ~ |
  as2 r |
  c,4 r8 es8 es r g4 ~ |
  g2 r |
  bes,4 r8 es8 es r g4 ~ |
  g2 r | \break
  
  es4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 f8 f r as4 ~ |
  as2 r |
  c,4 r8 g'8 g r c4 ~ |
  c4 d2 bes4 ~ |
  bes2 r4 g'4 ~ |
  \set Staff.midiMaximumVolume = #2.0
  g2 r8 c, \f es c |
  \inst "F"
  es4. ^\markup { "Trombone solo" } es8 ~ es2 |
  r4. c8 bes c r es | 
  f4. c8 ~ c2 |
  r4. as8 g as c es |
  g1 -> ~ |
  g2 r8 g r \grace { fis16 } g8 -> ~ |
  g4. \> f8 es d r c |
  r bes ~ bes2. \p | 
  
  \set Staff.midiMaximumVolume = #1.0
  r8 g \f as c es es c as |
  g as r c r es r f | \break
  r g, as c f f c as |
  g as r c r f r g ~ |
  g2 r8 c r c ~ |
  c2 r2 |
  \set Staff.midiMaximumVolume = #2.0
  r8 ges f es f -> \grace { es } r f -> \grace { es } r |
  f r f ges f es c bes |

  f'4 ^\markup { "Would I lie to you" } -> r2. |
  
  \set Staff.midiMaximumVolume = #1.0
  \set Score.skipBars = ##t R1*15
  
  \inst "G"
  \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
  r2. g,4 ~ -> \sp \< |
  g1 ~ |
  g2 \! r4 as -> \sp \< ~ 
  as1 ~ |
  as2 \! r2 |
  
  as8 -> as -> r4 as8 -> as -> r4 |
  \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. | \break
  
  as,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
  as2 r |
  f,4 r8 f'4 r8 as4 ~ |
  as2 r |
  c,4 r8 es8 es r g4 ~ |
  g2 r |
  bes,4 r8 es8 es r g4 ~ |
  g2 r |
  
  es4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 f8 f r as4 ~ |
  as2 r |
  c,4 r8 g'8 g r c4 ~ |
  c2 r4 f, -> ~ \< |
  f1 ~ |
  f2 \! r2 |
  
  \set Staff.midiMaximumVolume = #2.0
  \inst "H"
  r2 ^\markup { "Montuno - Petas" } r8 c \f es \tenuto f \tenuto |
  as \tenuto -> c, f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mf ~ d8 ( es \< f g -> \f ) ~ |
  g1 \> |
  r1 \mf | 
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  r2 r8 c' \f es \tenuto f \tenuto |
  as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mf ~ d8 ( es \< f es -> \f ) ~ |
  es1 \> ~ |
  es2 \mf r2 | 
  c1 -> \sp \< ~ |
  c2 ~ c8 ( es c f -> \f ~ |
  \inst "I"
  f4 ^\markup { "Coro Pregón" } ) r2. |
  R1 |
  d1 ~ -> \sp \< |
  d1 |
  es1 ~ -> \! \sp \< |
  es1 |
  f1 -> \! \sp \< |
  r2 \! c8 \mf ( es c f -> \f ~ |
  f4 ) r2. |
  R1 |
  d1 ~ -> \sp \< |
  d1 |
  es1 ~ -> \! \sp \< |
  es1 |
  c,4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  R1 |
  R1 |
  d''1 ~ -> \sp \< |
  d1 |
  es1 ~ -> \! \sp \< |
  es1 |
  f1 -> \! \sp \< |
  r2 \! c8 \mf ( es c f -> \f ~ |
  f4 ) r2. |
  R1 |
  d1 ~ -> \sp \< |
  d1 |
  es1 ~ -> \! \sp \< |
  es1 |
  c,4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  \set Staff.midiMaximumVolume = #1.0  
  
  R1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  f''1 -> \! \sp \< |
  r2 \! r8 \mf es ( c f -> \f ~ |
  f4 ) ^\markup { "A Capella" } r2. |
  \set Score.skipBars = ##t R1*7
  
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

  print-page-number = ##t
  print-first-page-number = ##t
  oddHeaderMarkup = \markup \fill-line { " " }
  evenHeaderMarkup = \markup \fill-line { " " }
  oddFooterMarkup = \markup {
    \fill-line {
      \bold \fontsize #2
      \on-the-fly #print-page-number-check-first
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
      \on-the-fly #print-page-number-check-first
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
    }
  }
}