\version "2.22.2"

% Sheet revision 2022_09

% for score rendering
% - comment \repeatBracket command
% - use simple page counter, only: \fromproperty #'page:page-number-string

\header {
  title = "Would I Lie"
  instrument = "score"
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


Trumpet = \new Voice
\transpose c d
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Tr. in Bb" }
  }
  \set Staff.midiInstrument = "trumpet"
  \set Staff.midiMaximumVolume = #1.0

  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
  R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
  g r8 c8 c4 r | \break
  
  \inst "A"
  r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
  c2 r |
  r4. as4 r8 c4 ~ |
  c2 r |
  r4. g8 g r c4 ~ |
  c2 r |
  r4. g8 g r bes4 ~ |
  bes2 r | \break
  
  c4 r8 es8 es r as4 ~ |
  as2 r |
  f4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 es es r g4 ~ |
  g4 r2. |
  es4 r8 g g r bes4 ~ |
  bes2. r4 | \break
  
  \inst "B"
  R1*11 ^\markup { "Verse 1" } 
  
  es4 d4. r8 c4 ~ |
  c1 |
  R1 | 
  R1 |
  
  r4 f2. \> |
  R1*3 \! | 
  
  r2 f 8 -> r f4 ~ -> \sp \< |
  f1 ~ |
  f2 \! r4 es ~ 
  es1 |
  r2 bes8 -> bes -> r4 | \break
  
  \inst "C"
  r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
  c2 r |
  r4. as4 r8 c4 ~ |
  c2 r |
  r4. g8 g r c4 ~ |
  c2 r |
  r4. g8 g r bes4 ~ |
  bes2 r | \break
  
  c4 r8 es8 es r as4 ~ |
  as2 r |
  f4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 es es r g4 ~ |
  g4 r2. |
  es4 r8 g g r bes4 ~ |
  bes2. r4 | \break
  \inst "D"
  R1*11 ^\markup { "Verse 2" } 
  
  es4 d4. r8 c4 ~ |
  c1 |
  \set Score.skipBars = ##t R1*3

  \inst "E"
  r8 ^\markup { "Swing!" } d \mf -. r4 d -> r8 d -. |
  R1 |
  r4 c8 -. r r c -. r4 |
  c8 -. r c8 -. r r4 g'8 -. r |
  r8 g -. r4 g -> r8 g -. |
  
  r2. as4 -> \sp \< ~ 
  as1 ~ |
  as2 \! r4 as4 -> | \break
  
  r4. ^\markup { "Chorus" } as,,4 r8 c4 ~ |
  c2 r |
  r4. as4 r8 c4 ~ |
  c2 r |
  r4. g8 g r c4 ~ |
  c2 r |
  r4. g8 g r bes4 ~ |
  bes2 r | \break
  
  c4 r8 es8 es r as4 ~ |
  as2 r |
  f4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 es es r g4 ~ |
  g4 r2. |
  es4 r8 g g r bes4 ~ |
  bes2. r4 | \break
  
  \inst "F"
  \set Score.skipBars = ##t R1*4 ^\markup { "Trombone solo" }
  
  c'1 ~ ( \pp \< |
  c2. ~ c8 bes \mf ~ |
  bes1 \> ~ |
  bes4 \bendAfter #-2 g2 \p ) \bendAfter #-4 r4 |
  
  r8 g, \f as c es es c as |
  g r as c r es r f |
  r g, as c f f c as |
  g r as c r f r g ~ |
  g2 \bendAfter #-3 r2 |
  
  \set Score.skipBars = ##t R1*3 \break
  
  \set Score.skipBars = ##t R1*16 ^\markup { "Would I lie to you" } \break
  
  \inst "G"
  \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
  r2. g,4 ~ -> \sp \< |
  g1 ~ |
  g2 \! r4 as -> \sp \< ~ 
  as1 ~ |
  as2 \! r2 |
  
  as8 -> as -> r4 as8 -> as -> r4 |
  \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. | \break
  
  r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
  c2 r |
  r4. as4 r8 c4 ~ |
  c2 r |
  r4. g8 g r c4 ~ |
  c2 r |
  r4. g8 g r bes4 ~ |
  bes2 r | \break
  
  c4 r8 es8 es r as4 ~ |
  as2 r |
  f4 r8 as8 as r c4 ~ |
  c2 r |
  c,4 r8 es es r g4 ~ |
  g2 r4 f' -> ~ \< |
  f1 ~ |
  f2 \! r2 | \break
  
  \set Staff.midiMaximumVolume = #2.0
  \inst "H"
  r2 ^\markup { "Montuno - Petas" } r8 c \f es \tenuto f \tenuto |
  as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mf ~ d8 ( es \< f g -> \f ) ~ |
  g1 \> |
  r1 \mf | 
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | \break
  
  \set Staff.midiMaximumVolume = #1.0
  
  r2 r8 c, \mf es \tenuto f \tenuto |
  as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mp ~ d8 ( es \< f es -> \mf ) ~ |
  es1 \> ~ |
  es2 \mp r2 | 
  c1 -> \sp \< ~ |
  c2 ~ c8 ( es c f -> \mf ~ | \break
  \inst "I"
  f4 ^\markup { "Coro Pregón" } ) r2. |
  R1 |
  g1 ~ -> \sp \< |
  g1 |
  c1 ~ -> \! \sp \< |
  c1 |
  c1 -> \! \sp \< |
  r2 \! c,8 \mf ( es c f -> \f ~ | \break
  f4 ) r2. |
  R1 |
  g1 ~ -> \sp \< |
  g1 |
  c1 ~ -> \! \sp \< |
  c1 |
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | \break
  
  R1 |
  R1 |
  g1 ~ -> \sp \< |
  g1 |
  c1 ~ -> \! \sp \< |
  c1 |
  c1 -> \! \sp \< |
  r2 \! c,8 \mf ( es c f -> \f ~ | \break
  f4 ) r2. |
  R1 |
  g1 ~ -> \sp \< |
  g1 |
  c1 ~ -> \! \sp \< |
  c1 |
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | \break
  
  R1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  c'1 -> \! \sp \< |
  r2 \! r8 \mf es, ( c f -> \f ~ | \break
  f4 ) ^\markup { "A Capella" } r2. |
  \set Score.skipBars = ##t R1*7
  
  \label #'lastPage
  \bar "|."
}


Sax = \new Voice
\transpose c a'
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
  R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
  g r8 c,8 c4 r | \break
  
  \inst "A"
  r4. ^\markup { "Chorus" } c4 r8 es4 ~ |
  es2 r |
  r4. c4 r8 f4 ~ |
  f2 r |
  r4. c8 c r es4 ~ |
  es2 r |
  r4. bes8 bes r es4 ~ |
  es2 r | \break
  
  as,4 r8 c8 c r es4 ~ |
  es2 r |
  as,4 r8 c8 c r f4 ~ |
  f2 r |
  g,4 r8 c8 c r es4 ~ |
  es4 r2. |
  g4 r8 bes bes r es4 ~ |
  es2. r4 | \break
  
  \inst "B"
  R1*11 ^\markup { "Verse 1" } 
  
  bes,4 bes4. r8 a4 ~ |
  a1 |
  R1 |
  R1 |
  
  r4 f2. \> |
  R1*2 \! |
  r4 es8 -. r r d -. r4 |
  es8 -. r f8 -. r c' -> r -. b4 ~ -> \sp \< |
  b1 ~ |
  b2 \! r4 c4 ~ |
  c1 | 
  r2 bes8 -> bes -> r4 | \break
  
  \inst "C"
  r4. ^\markup { "Chorus" } c4 r8 es4 ~ |
  es2 r |
  r4. c4 r8 f4 ~ |
  f2 r |
  r4. c8 c r es4 ~ |
  es2 r |
  r4. bes8 bes r es4 ~ |
  es2 r | \break
  
  as,4 r8 c8 c r es4 ~ |
  es2 r |
  as,4 r8 c8 c r f4 ~ |
  f2 r |
  g,4 r8 c8 c r es4 ~ |
  es4 r2. |
  g4 r8 bes bes r es4 ~ |
  es2. r4 | \break
  
  \inst "D"
  R1*11 ^\markup { "Verse 2" } 
  
  bes,4 bes4. r8 a4 ~ |
  a1 |
  \set Score.skipBars = ##t R1*3
  \inst "E"
  r8 ^\markup { "Swing!" } bes' \mf -. r4 bes -> r8 bes -. |
  R1 |
  r4 bes8 -. r r bes -. r4 |
  a8 -. r a8 -. r r4 f8 -. r |
  r8 f -. r4 f -> r8 f -. |
  r2. es4 ~ -> \sp \< |
  es1 ~ | 
  es2 \! r4 as4 -> | \break
  
  r4. ^\markup { "Chorus" } c,4 r8 es4 ~ |
  es2 r |
  r4. c4 r8 f4 ~ |
  f2 r |
  r4. c8 c r es4 ~ |
  es2 r |
  r4. bes8 bes r es4 ~ |
  es2 r | \break
  
  as,4 r8 c8 c r es4 ~ |
  es2 r |
  as,4 r8 c8 c r f4 ~ |
  f2 r |
  g,4 r8 c8 c r es4 ~ |
  es4 r2. |
  g4 r8 bes bes r es4 ~ |
  es2. r4 |
  
  \inst "F"
  \set Score.skipBars = ##t R1*4 ^\markup { "Trombone solo" }
  
  g,1 ~ ( \pp \< |
  g2. ~ g8 g8 \mf ~ |
  g1 \> ~ |
  g4 \bendAfter #-2 es2 \p ) \bendAfter #-4 r4 |
  
  r8 b \f c es as as es c |
  b r c es r as r as |
  r b, c f as as f c |
  b r c f r as r c ~ |
  c2 \bendAfter #-3 r2 |
  
  \set Score.skipBars = ##t R1*3
  
  \set Score.skipBars = ##t R1*16 ^\markup { "Would I lie to you" }
  
  \inst "G"
  \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
  
  r2. d,4 ~ -> \sp \< |
  d1 ~ |
  d2 \! r4 c4 ~ -> \sp \< |
  c1 ~ |  
  c2 \! r2 |
  
  as'8 -> as -> r4 as8 -> as -> r4 |
  \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. |
  
  r4. ^\markup { "Chorus" } c,4 r8 es4 ~ |
  es2 r |
  r4. c4 r8 f4 ~ |
  f2 r |
  r4. c8 c r es4 ~ |
  es2 r |
  r4. bes8 bes r es4 ~ |
  es2 r | \break
  
  as,4 r8 c8 c r es4 ~ |
  es2 r |
  as,4 r8 c8 c r f4 ~ |
  f2 r |
  g,4 r8 c8 c r es4 ~ |
  es2 r4 a, -> ~ \< |
  a1 ~ |
  a2 \! r2 |
  
  \set Staff.midiMaximumVolume = #2.0
  \inst "H"
  r2 ^\markup { "Montuno - Petas" } r8 c \f es \tenuto f \tenuto |
  as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mf ~ d8 ( es \< f g -> \f ) ~ |
  g1 \> |
  r1 \mf | 
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  \set Staff.midiMaximumVolume = #1.0
  
  r2 r8 c \mf es \tenuto f \tenuto |
  as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
  g2 ~ g8 f \tenuto -> \> r es \tenuto |
  d2 \tenuto \mp ~ d8 ( es \< f es -> \mf ) ~ |
  es1 \> ~ |
  es2 \mp r2 | 
  c1 -> \sp \< ~ |
  c2 ~ c8 ( es c f -> \mf ~ |
  \inst "I"
  f4 ^\markup { "Coro Pregón" } ) r2. |
  R1 |
  f1 ~ -> \sp \< |
  f1 |
  g1 ~ -> \! \sp \< |
  g1 |
  g1 -> \! \sp \< |
  r2 \! c,8 \mf ( es c f -> \f ~ |
  f4 ) r2. |
  R1 |
  f1 ~ -> \sp \< |
  f1 |
  g1 ~ -> \! \sp \< |
  g1 |
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  R1 |
  R1 |
  f1 ~ -> \sp \< |
  f1 |
  g1 ~ -> \! \sp \< |
  g1 |
  g1 -> \! \sp \< |
  r2 \! c,8 \mf ( es c f -> \f ~ |
  f4 ) r2. |
  R1 |
  f1 ~ -> \sp \< |
  f1 |
  g1 ~ -> \! \sp \< |
  g1 |
  c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
  g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
  
  R1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  g1 -> \! \sp \< |
  r2 \! r8 \mf es ( c f -> \f ~ |
  f4 ) ^\markup { "A Capella" } r2. |
  \set Score.skipBars = ##t R1*7
  
  \label #'lastPage
  \bar "|."
}

Trombone = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Trombone" }
  }
  \set Staff.midiInstrument = "trombone"
  \set Staff.midiMaximumVolume = #1.0

  \clef bass
  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
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

upper = \new Voice \relative c'' {
    \set PianoStaff.instrumentName = \markup {
      \center-align { "Piano" }
    }
    \set Staff.midiInstrument = "piano"
    \set Staff.midiMaximumVolume = #0.7

    \clef treble
    \key c \minor
    \time 4/4
  \tempo "Fast Salsa" 4 = 210
    
    \set Score.skipBars = ##t R1*14 ^\markup { "A Capella" }
    
    \tuplet 3/2 { <c, c'>4 <c c'> <c c'> } \tuplet 3/2 { <es es'> <es es'> <es es'> } | 
    <g g'> r8 <c c'>8 <c c'>4 r |
    
      \inst "A"
    <es es'>8 ^\markup { "Chorus" } as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    \ottava #1
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
    <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
    
    <es es'>8 as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <f f'> ~ <f f'> <g bes> <f f'>4 |
    <bes, bes'> <es es'> ~ <es es'> \ottava #0 <c, f a> ~ |
    
      \inst "B"
    <c f a>1 ^\markup { "Verse 1" }  ~ |
    <c f a> |
    \makePercent s1
    
    <g'' bes es>4 <g bes d>4. r8 <f a c>4 ~ |
    <f a c>1 |
     \makePercent s1
     
     s1*0 ^\markup { "Improvisation" }
      \repeat percent 2 { \makePercent s1 }
          \repeat percent 3 { \makePercent s1 }
    
    <g, bes es>4 <g bes d>4. r8 <f a c>4 ~ |
    <f a c>1 |
    \makePercent s1
         s1*0 ^\markup { "Improvisation" }
  \repeat percent 2 { \makePercent s1 }
  \repeat percent 7 { \makePercent s1 }
    r2 <bes' bes'>8 -> <bes bes'> -> r4 |
    
      \inst "C"
    <es, es'>8 ^\markup { "Chorus" } as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    \ottava #1
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
    <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
    
    <es es'>8 as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <f f'> ~ <f f'> <g bes> <f f'>4 |
    <bes, bes'> <es es'> ~ <es es'> \ottava #0 <c, f a> ~ |
    
      \inst "D"
    <c f a>1 ^\markup { "Verse 2" }  ~ |
    <c f a> |
    \makePercent s1
    
    <g'' bes es>4 <g bes d>4. r8 <f a c>4 ~ |
    <f a c>1 |
    \makePercent s1
    s1*0 ^\markup { "Improvisation" }
      \repeat percent 2 { \makePercent s1 }
            \repeat percent 3 { \makePercent s1 }
    
    <g, bes es>4 <g bes d>4. r8 <f a c>4 ~ |
    <f a c>1 |
      \repeat percent 3 { \makePercent s1 }
        \inst "E"
        s1*0 ^\markup { "Swing!" }
      \repeat percent 8 { \makePercent s1 }
    
    
    <es' es'>8 ^\markup { "Chorus" } as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    \ottava #1
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
    <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
    
    <es es'>8 as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <f f'> ~ <f f'> <g bes> <f f'>4 |
    <bes, bes'> <es es'> ~ <es es'> r4 |
    
      \inst "F"
    \ottava #0
    <es es'>8 ^\markup { "Trombone solo" } as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    \ottava #1
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
    <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
    
    <es es'>8 as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <f f'> ~ <f f'> <g bes> <f f'>4 |
    <bes, bes'> <es es'> ~ <es es'> r4 |
    
    f'4 ^\markup { "Would I lie to you" } -> r2. |
    \ottava #0
    
    \set Score.skipBars = ##t R1*15
    
      \inst "G"
    s1*0 ^\markup { "Te digo" }
          \repeat percent 8 { \makePercent s1 }
    \ottava #1
    <as, as'>8 -> <as as'> -> r4 <as as'>8 -> <as as'> -> r4 |
    \tuplet 3/2 { <as as'>4 -> <as as'> -> <as as'> -> } <as as'>8 -> r4. |
    
    \ottava #0
    <es es'>8 ^\markup { "Chorus" } as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    \ottava #1
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
    <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
    
    <es es'>8 as c <c, c'> ~ <c c'> es as r |
    <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
    <f f'> as c <c, c'> ~ <c c'> f as r |
    <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
    <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> <f f'>4 -> ~ |
    <f f'>1 ~ |
    <f f'>2 r2 |
    
      \inst "H"
    \ottava #0
    r4 ^\markup { "Montuno - Petas" } <c c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
    \ottava #0
    r4 <c, c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
          \inst "I"
    \ottava #0
    r4 ^\markup { "Coro Pregón" } <c, c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
    \ottava #0
    r4 <c, c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
    \ottava #0
    r4 <c, c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
    \ottava #0
    r4 <c, c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
    <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
    <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
    <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
    \ottava #1
    <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
    <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
    <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
    
    R1 ^\markup { "Fade out" } |
    R1 |
    R1 |
    R1 |
    R1 |
    R1 |
    R1 |
    R1 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "A Capella" }
      
    \bar "|."  
}

lower = \new Voice \relative c {
    \set PianoStaff.instrumentName = \markup {
      \center-align { "Piano" }
    }
    \set Staff.midiInstrument = "piano"
    \set Staff.midiMaximumVolume = #0.7

    \clef bass
    \key c \minor
    \time 4/4
    
    \set Score.skipBars = ##t R1*14
    
    \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
    g r8 c8 c4 r |
    
    \clef treble
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
    g <bes es> f f ~ f es ~ es es |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> f ~ f <g bes> f4 |
    bes, es ~ es f4 ~ |
    
    f1 ~ |
    f1 |
    
   \makePercent s1
    
    g4 g4. r8 f4 ~ |
    f1 |
    
      \repeat percent 6 { \makePercent s1 }
    
    \clef bass
    g,4 g4. r8 f4 ~ |
    f1 |
      \repeat percent 10 { \makePercent s1 }
    r2 bes8 -> bes -> r4 |
    
    \clef treble
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
    g <bes es> f f ~ f es ~ es es |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> f ~ f <g bes> f4 |
    bes, es ~ es f4 ~ |
    
    f1 ~ |
    f1 |
    
    \makePercent s1
    
    g4 g4. r8 f4 ~ |
    f1 |
    
      \repeat percent 6 { \makePercent s1 }
    
    \clef bass
    g,4 g4. r8 f4 ~ |
    f1 |
      \repeat percent 3 { \makePercent s1 }
          \repeat percent 8 { \makePercent s1 }
    
    \clef treble
    es'8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
    g <bes es> f f ~ f es ~ es es |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> f ~ f <g bes> f4 |
    bes, es ~ es r4 |

    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
    g <bes es> f f ~ f es ~ es es |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> f ~ f <g bes> f4 |
    bes, es ~ es r4 |


    f4 -> r2. |
    
    \set Score.skipBars = ##t R1*15
    
    s1*0
          \repeat percent 8 { \makePercent s1 }
    
    as8 -> as -> r4 as8 -> as -> r4 |
    \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f ~ f fis |
    g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
    g <bes es> f f ~ f es ~ es es |
    
    es8 as c c, ~ c es as r |
    es as c c, ~ c es ~ es e |
    f as c c, ~ c f as r |
    f as c c, ~ c f ~ f fis |
    g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
    g4 <c es>8 es, ~ es f f4 -> ~ |
    f1 ~ |
    f2 r2 |
    
    \clef bass
    <es, as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c>4 \tenuto <f a bes c> \tenuto |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>2 <f a bes c> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    <es as c>1 ~ |
    <es as c> |
    <b' d g> ~ |
    <b d g> |
    <c, es g bes> ~ |
    <c es g bes>1 |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    \clef treble 
    <c' es f as>1 ~ |
    <c es f as> |
    <d f g> ~ |
    <d f g> |
    \clef bass
    <g, as c es> ~ |
    <g as c es> |
    <f a bes c>1 ~ |
    <f a bes c> |
    
    \label #'lastPage
    \bar "|."  
}

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
  as,4. ^\markup { "Chorus" } es'4. as4 ~ |
  as4. es4. as,4 |
  \ottava #-1
  f4. c'4. f4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. bes4. es,8 es |
  
  as4. es'4. as4 ~ |
  as4. es4. as,4 |
  f4. c4. f'4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. es,4. f4 ~ |
  
  \inst "D"
  f1 ^\markup { "Verse 2" }  ~ |
  f |
  R1 |
  
  \ottava #0
  r4 b8 ( c4 ) r8 f4 ~ |
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
  
  as4. ^\markup { "Chorus" } es'4. as4 ~ |
  as4. es4. as,4 |
  \ottava #-1
  f4. c'4. f4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. bes4. es,8 es |
  
  as4. es'4. as4 ~ |
  as4. es4. as,4 |
  f4. c4. f'4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. es,4. r4 |
  
  \inst "F"
  \ottava #0
  as4. ^\markup { "Trombone solo" } es'4. as4 ~ |
  as4. es4. as,4 |
  \ottava #-1
  f4. c'4. f4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. bes4. es,8 es |
  
  as4. es'4. as4 ~ |
  as4. es4. as,4 |
  f4. c4. f'4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. es,4. r4 |
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
  
  \ottava #0
  as4. ^\markup { "Chorus" } es'4. as4 ~ |
  as4. es4. as,4 |
  \ottava #-1
  f4. c'4. f4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. g'4 |
  es4. bes'4. es4 ~ |
  es4. bes4. es,8 es |
  
  as4. es'4. as4 ~ |
  as4. es4. as,4 |
  f4. c4. f'4 ~ |
  f4. f,4. c4 |
  c4. g'4. c4 ~ |
  c4. c,4. \ottava #0 f'4 ~ |
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
    %\repeatBracket 4 {
      as4. es'4. as4 ~ |
      as4. es4. f4 |
      g4. d4. r4 |
      g,4. d'4. r4 |
      c,4. d4. r4 |
      es4. e4. r4 |
      f4. c'4. f4 ~ |
      f4. c8 ~ c f, as as |
    %}
  }
  
  as1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  
  as1 ^\markup { "A Capella" }  ~ |
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

Congas = \new DrumVoice \drummode {
  
  \set DrumStaff.instrumentName = \markup {
    \center-align { "Conga" }
  }

  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
  R1*14 ^\markup { "A Capella" }    
  
  \tuplet 3/2 { cgh4 cgh cgh } \tuplet 3/2 { cgh cgh cgh } | 
  cgh r8 cgh8 cgh4 r |
  
  \inst "A"
  s1*0 ^\markup { "Chorus (tumbao 3/2)" }
  \repeat percent 8 {
    bol8 bolm ssh cglo cglo bolm cgho cgho |
    bolm bolm ssh bolm bolm bolm cgho cgho |
  }
  
  \inst "B"
  s1*0 ^\markup { "Verse 1 (tumbao + maracas)" }
  \repeat percent 8 {
    bolm8 bolm ssh cglo cglo bolm cgho cgho |
    bolm bolm ssh bolm bolm bolm cgho cgho |
  }
  
  cgh8 ^\markup { "(tumbao + martillo + cascara 2-3)" } bolm ssh bolm cgh bolm cglo bolm |
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm cglo bolm |
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm r4 |
  R1 |
  R1 |
  
  \inst "C"
  s1*0 ^\markup { "Chorus (tumbao 3/2)" }
  \repeat percent 8 {
    cgh8 bolm ssh cglo cglo cgh cgho cgho |
    cgh bolm ssh bolm cgh bolm cgho cgho |
  }
  
  \inst "D"
  s1*0 ^\markup { "Verse 2 (tumbao + maracas)" }
  \repeat percent 8 {
    bolm8 bolm ssh cglo cglo bolm cgho cgho |
    bolm bolm ssh bolm bolm bolm cgho cgho |
  }
  
  \inst "E"
  cgh8 ^\markup { "Swing!" } bolm ssh bolm cgh bolm cglo bolm |
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm cglo bolm |
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm cglo bolm |
  
  cgh bolm ssh bolm cgh bolm r4 |
  R1 |
  R1 |
  
  s1*0 ^\markup { "Chorus (tumbao 3/2)" }
  \repeat percent 8 {
    bol8 bolm ssh cglo cglo bolm cgho cgho |
    bolm bolm ssh bolm bolm bolm cgho cgho |
  }
  
  \inst "F"
  s1*0 ^\markup { "Trombone solo (tumbao 3/2)" }
  \repeat percent 8 {
    bol8 bolm ssh cglo cglo bolm cgho cgho |
    bolm bolm ssh bolm bolm bolm cgho cgho |
  }
  
  s1*0 ^\markup { "Would I lie to you (conga tumbao slaps + guiro)" }
  \repeat percent 6 {
    bol8 bolm ssh r r bolm cgho cgho |
    bolm bolm ssh r r bolm cgho cgho |
  }
  
  ssh -> r r2. |
  \set Score.skipBars = ##t R1*3
  
  \inst "G"
  s1*0 ^\markup { "Te digo" }
  \repeat percent 4 {
    cglo8 r cglo r cglo r cglo r |
    cglo r cglo r cglo r cglo r |
  }
  cgho cgho cglo r cgho cgho cglo r |
  \tuplet 3/2 { cgho4 cgho cgho } cgho8 cglo r4 |
  
  s1*0 ^\markup { "Chorus (tumbao 3/2)" }
  \repeat percent 8 {
    cgh8 bolm ssh cglo cglo cgh cgho cgho |
    cgh bolm ssh bolm cgh bolm cgho cgho |
  }
  
  \inst "H"
  s1*0 ^\markup { "Montuno - Petas (tumbao 3/2)" } 
  \repeat percent 8 {
    cgh8 bolm ssh cglo cglo cgh cgho cgho |
    cgh bolm ssh bolm cgh bolm cgho cgho |
  }
  
  \inst "I"
  s1*0 ^\markup { "Coro Pregón (tumbao 3/2)" }
  \repeat percent 16 {
    cgh8 bolm ssh cglo cglo cgh cgho cgho |
    cgh bolm ssh bolm cgh bolm cgho cgho |
  }
  
  s1*0 ^\markup { "Fade out (tumbao 3/2)" }
  \repeat percent 4 {
    cgh8 bolm ssh cglo cglo cgh cgho cgho |
    cgh bolm ssh bolm cgh bolm cgho cgho |
  }
  
  R1*8 ^\markup { "A Capella" } 
  
  \label #'lastPage
  \bar "|."
}

Timbales = \new DrumVoice \drummode {
  \set Staff.instrumentName = \markup {
    \center-align { "Timbales" }
  }

  \time 4/4
  \tempo "Fast Salsa" 4 = 210

  R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { cb4 cb cb } \tuplet 3/2 { cb cb cb} | 
  timh r8 timl8 timl4 cymc -^ |
  
  \inst "A"
  s1*0 ^\markup { "Chorus (campana 3/2)" }
  \repeat percent 8 {
    r8 cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "B"
  R1*16 ^\markup { "Verse 1 (tumbao + maracas)" } 
  
  
  hhc8-. ^\markup { "(tumbao + martillo + cascara 2-3)" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
  
  hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  r2 timh8 timh r timh |
  r timh timl timl cb -^ cb -^ r4 |
  
  \inst "C"
  s1*0 ^\markup { "Chorus (campana 3/2)" } 
  \repeat percent 8 {
    r8 cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "D"
  R1*16 ^\markup { "Verse 2 (tumbao + maracas)" } 
  
  \inst "E"
  hhc8-. ^\markup { "Swing!" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
  
  hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  timh timl r timl r timl cymc4 -^ |
  
  s1*0 ^\markup { "Chorus (campana 3/2)" }
  \repeat percent 8 {
    r8 cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "F"
  s1*0 ^\markup { "Trombone solo (campana 3/2)" }
  \repeat percent 8 {
    r8 cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  rb8 -. ^\markup { "Would I lie to you (camp. + contrac.)" } ^\markup { "Timbal Solo" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
  cymc -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
  cymc -^ ^\markup { "Timbal Solo" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
  cymc -^ r r2. |
  
  \set Score.skipBars = ##t R1*3
  
  \inst "G"
  hh8 ^\markup { "Te digo (hh / cymbal)" } r hh r hh r hh r |
  hh r hh r hh r hh r |
  hh r hh r hh r hh r |
  hh r hh r hh r cymc -^ r |
  hh r hh r hh r hh r |
  hh r hh r hh r hh r |
  hh r hh r hh r hh r |
  hh r hh r hh r hh r |
  
  timl timl cymc -^ r timl timl cymc -^ r |
  \tuplet 3/2 { timl4 timl timl } timl8 cymc -^ r4 |
  
  s1*0 ^\markup { "Chorus (camp. + contrac.)" }
  \repeat percent 6 {
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb cymc4 -^ |
  rb8 -. cb <<cb hhho>> timl timh timh r timl |
  r timh r timh r2 |
  
  \inst "H"
  cymc8 -^ ^\markup { "Montuno - Petas (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  \repeat percent 3 {
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  
  rb8 -. cb cymc -^ cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  \repeat percent 2 {
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  
  rb8 -. cb <<cb hhho>> cb rb -. timh timh timh | 
  timh timh r4 r2 |
  
  \inst "I"
  cymc8 -^ ^\markup { "Coro Pregón (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  timl timl cymc -^ r timl timl cymc -^ r |
  timl timl cymc -^ r timl timh timh r |
  
  cymc8 -^ ^\markup { "Fade out (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -.  cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -.  cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  R1*8 ^\markup { "A Capella" }    
  
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
  
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  bes | bes | f | f |
  g | g | as | as |
  
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  as | as | f:m | f:m |
  c:m | c:m | es | es |
  
  f | r1*7 | r1*8
  
  bes1 | bes | f/a | f/a |
  g | g | as | as |
  as | as |
  
  as | as | f:m | f:m |
  c:m | c:m | es | es |
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
  as | as | g | g |
  c:m | c:m | f | f |
  as | as | g | g |
  c:m | c:m | f | f |
}

\score {
   \compressMMRests \unfoldRepeats {
        \new StaffGroup \with {
        \consists "Volta_engraver"
        }<<
            \new Staff << \Trumpet >>
            \new Staff << \Sax >>
            \new Staff << \Trombone >>
                \Chords
            \new PianoStaff <<
              \set PianoStaff.instrumentName = #"Piano  "
              \new Staff = "upper" \upper
              \new Staff = "lower" \lower
            >>
            \new Staff << \Bass >>
            \new DrumStaff \with {
              drumStyleTable = #congas-style
              \override StaffSymbol.line-count = #2
              \override BarLine.bar-extent = #'(-1 . 1) 
            }  
            <<
              \Congas
            >>
            \new DrumStaff \with {
              drumStyleTable = #timbales-style
              \override StaffSymbol.line-count = #2
              \override BarLine.bar-extent = #'(-1 . 1)
            }
            <<
              \Timbales
            >>
        >>
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
      \on-the-fly #print-page-number-check-first
      %\concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
      \fromproperty #'page:page-number-string 

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
      %\concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
      \fromproperty #'page:page-number-string
    }
  }
}