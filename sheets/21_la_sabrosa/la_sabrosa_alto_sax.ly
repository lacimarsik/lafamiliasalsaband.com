\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "La Sabrosa"
  instrument = "sax"
  composer = "by Fernando Sosa & Massimo Scalici"
  arranger = "arr. Luca Colella"
  opus = "version 22.2.2023"
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

Sax = \new Voice
\transpose bes, g
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \key d \minor
  \time 4/4
  \tempo "Slower Salsa" 4 = 180
 
  s1*0 \set Score.skipBars = ##t R1*18 ^\markup { "Intro piano" } \fermata
  \inst "A"
 
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Piano montuno" }
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Salsa" }
  s1*0 
  ^\markup { "Brass" }
 
  \break
  \inst "B"
  R1 |
  r8 b cis d e f g a |
  r f r2 r4 |
  r8 cis c cis e cis e d |
  r8 f r2 r4 |
  r8 b, cis d e f g a |
  r f8 r2 r4 |
  r8 cis c cis e cis e d | \break
 
  \inst "C"
  f8 ^ "Trumpets" e f a r f r g | 
  r8 f8 e8 d8 cis8 e8 
  g4 ~ |
  g4 r4 r2 |
  r2 r8 f8  g8 r8 |
  a4. g4. r4 |
  g4. f4. r4 |
  e'8 r8 a,8 r8 cis4. d8 |
  r4. d4 r8 r4 | \break
 
  \inst "D"
  r2 ^ "Coro 1" r4 r8 g,8 |
  r8 e8 r8 bes'8 a8 g8  a4 |
  r8 g8  fis8 g8 bes8 g8
  bes8 a8 | 
  r8 f8 r4 r8 f8  g8 a8 |
  a4. g4. r4 |
  g4. f4. r4 |
  R1 |
  f8 r8 f8  f8 r2 | \break

  \inst "E"
  r2 ^ "Solo Cantante 1" r4 r8 e8 |
  r8 e8 r8 f8  g8 e8 f8
  g8 |
  r8 e8 r2 r4 |
  r8 f8  g8 a8 r8 f4 r8 |
  a4. g4. r4 | 
  g4. f4. r4 |
  r8 a8  g8 f8 g8 a8 r8
  f8 | 
  r8 g8 r8 a8 r4 d4 ~ | 
  d4 r4 r2 |
  r8 e,8 r8 f8  g8 e8 f8
  g8 |
  r8 e8 r8 e2 r8 |
  r8 f8  g8 a8 r8 f4 r8 |
  a4. g4. r4 |
  g4. f4. r4 |
  r8 a8  g8 f8 g8 a8 r4 |
  a8 r8 a8  a8 r4 a4 ~ | \break
  \inst "F"
  a4 ^ "Coro 2" r4 r2 |
  r4 r8 f8 e8 d8 e4 |
  r8 cis8  c8 cis8
  e8 cis8 e8 d8 |
  r8 f4 r4 f8  g8 a8 |
  a4. g4. r4 |
  g4. f4. r4 |
  R1 |
  f8 r8 f8  f8 r2 | \break
 
  \inst "G"
  R1 ^ "Solo Cantante 2" | 
  r8 e8 r8 f8  g8 e8 f8
  g8 |
  r8 e8 r2 r4 |
  r8 f8  g8 a8 r8
  f4 r8 |
  a4. g4. r4 |
  g4. f4. r4 |
  r8 a8  g8 f8  g8 a8 r4 |
  f8 r8 g8  a8 r4 f4 ~ | 
  f4 r2 r4 |
  r8 e8 r8 g8  e8 f8 g8 s8
  | % 59
  r8 e8 r8 e2 r8 |
  r8 f8  g8 a8 r8 r4 r8 |
  a4. g4. r4 | 
  g4. f4. r4 |
  r8 a8  g8 f8 g8 a8 r4 |
  a8 r8 a8  a8 r4 a4 ~ | \break

  \inst "H"
  a4 ^ "Coro y Pregón" r4 r2 |
  r2 r8 e8  f8 g8 |
  r8 e4 r8 r2 | 
  r2 r8 a8 r8 a8 ~ | 
  a2. r4 | 
  s1*0 \set Score.skipBars = ##t R1*3 \break
  R1 | 
  r2 r8 e8  f8 g8 | 
  r8 e4 r8 r2 | 
  r2 r8 d8  e8 f8 ~ | 
  f4 r4 r2 | 
  s1*0 \set Score.skipBars = ##t R1*3 \break
  R1 | 
  r2 r4 r8 e8 |
  r8 g8 r4 r2 | 
  r2 r8 e8 r8 d8 ~ | 
  d2. r4 | 
  s1*0 \set Score.skipBars = ##t R1*3 \break
  R1 | 
  r4 r8 f8  e8 d8  e4 | 
  r8 cis8  c8 cis8 e8 cis8
  e8 d8 | 
  r8 f4 r4 f8  g8 a8 | 
  a4. g4. r4 | 
  g4. f4. r4 | 
  R1 |
  f8 r8 f8  f8 r2 | \break
  \inst "I"
  s1*0 \set Score.skipBars = ##t R1*8 ^\markup { "Piano solo introduction" }
  s1*0 \set Score.skipBars = ##t R1*32 ^\markup { "Piano solo" }
  s1*0 \set Score.skipBars = ##t R1*16 ^\markup { "Conga solo" } \break
 
  \inst "J"
  R1 ^ "Brass + Solos" |
  r8   b,8  cis8 d8 e8 f8
  g8 a8 |
  r8 f8 r2 r4 |
  r8 cis8  c8 cis8 e8 cis8
  e8 d8 |
 
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Solo Trombono" } \break

  R1 | 
  r8 b8  cis8 d8 e8 f8
  g8 a8 | 
  r8 f8 r2 r4 |
  r8 cis8  c8 cis8 e8 cis8
  e8 d8 |
 
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Solo Trumpet" } \break
 
  \inst "J"
  f,8 ^ "Brass + Solos" e f g a f g a |
  bes g a bes c d b cis -- |
  r bes -- r a -- r g -- r f -- ~ |
  f4 r8 g8 f4 r |
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Solo Trombono" } \break

  f8 e f g a f g a |
  bes g a bes c d b cis -- |
  r bes -- r a -- r g -- r f -- |
  r4. g8 f4 r |
 
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Solo Trumpet" } \break
 
  \inst "K"
  R1 ^ "Coda (Coro y Pregón)" | 
  r2 r8 e8  f8 g8 | 
  r8 e4 r8 r2 | 
  r2 r8 a8 r8 a8 ~ | 
  a2. r4 | 
  s1*0 \set Score.skipBars = ##t R1*3 | \break
  R1 |
  r4 r8 f'8  e8 d8  e4 | 
  r8 cis8  c8 cis8 e8 cis8
  e8 d8 | 
  r8 f4 r4 f8  g8 a8 | 
  a4. g4. r4 | 
  g4. f4. r4 | 
  R1 |
  f8 r8 f8  f8 r2 | \break
 
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \Sax
  }
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
}

\score {
  \unfoldRepeats {
    \transpose g bes, \Sax
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