\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#17 Sera Que No Me Amas"
  instrument = "tenor sax"
  composer = "by Tony Succar feat. Michael Stuart"
  arranger = "arr. Ladislav Maršík"
  opus = "version 25.8.2024"
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
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \clef treble
  \key c \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190  
    
  s1*0 ^\markup { "Intro" }
  \inst "A"
  c'4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g4. | \break

  \mark \markup { \musicglyph "scripts.segno" }
    s1*0 ^\markup { "Verse 1 & 3" }
  \inst "B"
  c4 \accent  \bendAfter #-4  r2. | 
  \set Score.skipBars = ##t R1*2
  r8 e8 -. \accent \f r2. |
  \set Score.skipBars = ##t R1*2
  f,4 \mf \tenuto ( g -. ) r4 c \f \accent ~ |
  c8 e -. r g -. r e ( d -. )  r | \break
  R1 |
  r8 a' ( g e g a -. ) r4  |
  r2 e4 \f \tenuto e -. |
  e4 \tenuto ( e8 g e4 -.  \tenuto ) r | 
  r4. f8 -. \accent \f r2 |
  r4. c8 -. \accent ~ c8 \bendAfter #-4 r4. |
  r4. g'8 ( g e g g -. ) |
  r8  g, -. r2. | \break
  r2 ^\markup { "Chorus " }  r8 g a -. r | 
  c \f \tenuto \accent c \tenuto \accent r2. |
  r4. \mf es8 r f r bes | 
  r g8 ~ g r8 f f bes,8 r  | \break
  r2. d8 ^\markup { "Sax D" }  -. \accent \f r |
  r8 d8 -. \accent r2. |
  r4. g8 \mf r a ~ a4 |
  r8 g a -. r g a \tenuto ~ a r | \break
  r2r8 g, a r | 
  r c \tenuto \accent ~ c4 r2 |
  r4. es8 r f r bes | 
  r g ~ g r f f bes,8 r  | \break
  r2. d8 ^\markup { "Sax D" } -. \accent \f r |
  r8 d8 -. \accent r2. |
  r8 g8 \mf  \tenuto d \tenuto dis \tenuto  e \tenuto g \tenuto e \tenuto a -. \accent  |
  R1 | \break
  c2^\markup { "Verse, Sax C" } \accent  \bendAfter #-4  r2 | 
  \set Score.skipBars = ##t R1*2
  r8 c8 -. \accent \f r2. |
  \set Score.skipBars = ##t R1*2
  f,2 \mf r4 e \accent ~ |
  e8 e \tenuto \f r g \tenuto r e ( d )  r | \break
  R1 |
  r8 a' ( g e g a -. ) r4  |
  r2 e4 \f \tenuto e -. |
  e4 \tenuto ( e8 g e4 -.  \tenuto ) r | 
  r4. f8 -. \accent \f r2 |
  r4. c8 -. \accent ~ c8 \bendAfter #-4 r4. |
  r4. g'8 ( g e g g -. ) |
  r8  g, -. r2. | \break
  r2 ^\markup { "Chorus " }  r8 g a -. r | 
  c \f \tenuto \accent c \tenuto \accent r2. |
  r4. \mf es8 r f r bes | 
  r g8 ~ g r8 f f bes,8 r  | \break
  r2. d8 ^\markup { "Sax D" }  -. \accent \f r |
  r8 d8 -. \accent r2. |
  r4. g8 \mf r a ~ a4 |
  r8 g a -. r g a \tenuto ~ a r | \break
  r2r8 g, a r | 
  r c \tenuto \accent ~ c4 r2 |
  r4. es8 r f r bes | 
  r g ~ g r f f bes,8 r  | \break
  r2. d8 ^\markup { "Sax D" } -. \accent \f r |
  r8 d8 -. \accent r2. |
  r4. g,8 \mf   r c r a' | 
  r g ~ g r e d e  r  | \break
  \set Score.skipBars = ##t R1*8 ^\markup { "Ya No Se" }
  
  r2 r8 c'8 ~-. \accent \f c4 |
  r2 r8 c,8  \mf \accent ~ c4 |
  r4. a'8 \f -. r a g g \accent -. |
  R1  | \break
  
  r2 r8 c8 ~-. \accent \f c4 |
  R1 |
  d,,4 \mf ~ d8  \tenuto a'8 ~ a4 ~ a8 \tenuto bes ~ |
  bes4 ~ bes8  g8 \f  ~ g2 | \break
  \mark \markup { \musicglyph "scripts.coda" } 
  a8 ^\markup { "Chorus" }  -. \accent  r4. r8 g a -. r | 
  c \f \tenuto \accent c \tenuto \accent r2. |
  r4. \mf es,8 r f r bes | 
  r g8 ~ g r8 f f bes,8 r  | \break
  r2. f'8 ^\markup { "Sax D" }  -. \accent \f r |
  r8 f8 -. \accent r2. |
  r4. g8 \mf r a ~ a4 |
  r8 g a -. r g a \tenuto ~ a r | \break
  r2r8 g a r | 
  r c \tenuto \accent ~ c4 r2 |
  r4. es8 r f r bes | 
  r g ~ g r f f bes,8 r  | \break
  r2. f'8 ^\markup { "Sax D" } -. \accent \f r |
  r8 f8 -. \accent r2. |
  r8 g8 \mf  \tenuto d \tenuto dis \tenuto  e \tenuto g \tenuto e \tenuto a -. \accent  |
  R1 | \break
  
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trombone (C, E, F, G)" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Sax" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Piano" } |
  r1 \fermata ^\markup { "Wait for apel" } | |
  
  g8 \f g -. r g -. r g ~ g4 \tenuto  ^\markup { "D.S. al Coda" } | \break

  \repeat volta 4 {
    \set Score.skipBars = ##t R1*2 ^\markup { "Coda1 4x" } |
    c,8 c r a r c r d |
    r es r e r g a g |   \break
  }
  \repeat volta 4 {
    c,8  ^\markup { "Coda2 3x" } c r a r c r d \fermata ^\markup { "wait on D on 3rd" } |
    r es r e r g a g |   \break 
  }

  c,8 c r a r c r d |
  r es r e r g a g |   
  c8 \accent r8 r2. |
  
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