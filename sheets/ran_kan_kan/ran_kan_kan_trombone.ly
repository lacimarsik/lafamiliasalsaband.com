\version "2.24.0"

% Sheet revision 2022_09


\header {
  title = "Ran Kan Kan"
  instrument = "trombone"
  composer = "by Croma Latina"
  arranger = "arr. Ladislav Maršík, Luca Colella"
  opus = "version 27.4.2023"
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

Trombone = \new Voice \relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Trombone" }
  }
  \set Staff.midiInstrument = "trombone"
  \set Staff.midiMaximumVolume = #1.0

  \clef bass
  \key d \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190
  
  \inst "A"
  s1*0 ^\markup { "Intro" }
  d4 \f -> r d -> r |
  d -> r8 c r e r c |
  d4 -> r8 c r e r c |
  d4 -> d -> d -> r |
  R1 |
  d4 -> d -> d -> r8 d -> |
  r d -> r2. | \break
  
  \inst "B"
  s1*0 ^\markup { "Brass" }
  \repeat volta 2 {
    d4 ( d c e -. ) |
    d4. \tenuto -> a8 ~ a \tenuto r4. |
    a'4 -> a -> a -> r8 a -> |
    r a -> r2. | \break 
  }
  d,4 ( d c e -. ) |
  d4. \tenuto -> a8 ~ a \tenuto r4. | \break

  \inst "C"
  s1*0 ^\markup { "Verso" }
  \set Score.skipBars = ##t R1*16 |

  d4 -> d -> d -> r |
  R1 | \break 
  
  \inst "D"
  s1*0 ^\markup { "Brass 2" }
  \repeat volta 2 {
    d,,2 -> d2 -> |
    r4 a'8 \tenuto a -. r a \tenuto a -. r  | 
    d,2 -> d2 -> |
    r4. a'8 \tenuto r a \tenuto a -. r  |  \break
  }

  \inst "E"
  s1*0 ^\markup { "Ran Kan Kan" }
  d,2 \tenuto -> r2 |
  \set Score.skipBars = ##t R1*15 |
  
  \inst "F"
  s1*0 ^\markup { "Puente" }
  \repeat volta 2 {
    d2 -> r2 |
    r4. fis8 \tenuto r fis \tenuto a -. r | 
    d,2 -> r2 |
    r8 a' \tenuto r d \tenuto d \tenuto d \tenuto d \tenuto r | 
    d,2 -> r2 |
    r4. fis8 \tenuto r fis \tenuto a -. r | 
  }
  
  \alternative {
    { 
      d,2 -> r2 |
      r8 a' \tenuto r d \tenuto d \tenuto d \tenuto d \tenuto r |
    }
    {
      d,2 -> r4. a'8 \tenuto ~ |
      a r d \f -> d -> d -> d -> r4 |
    } 
  } \break
  
  r4. bes'8 ( c e -. ) r g ( |
  gis1 ) \tenuto |
  
  c,8 ( \mp \< a c e ~ e c e fis ~ |
  fis1 ) \f -> | \break
  
  \inst "G"
  s1*0 ^\markup { "Reggaeton" }
  \set Score.skipBars = ##t R1*16 |  \break
  
    \inst "H"
  s1*0 ^\markup { "Petas" }
  \repeat volta 2 {
    a,2 \f -> fis8 ( \> d a  gis' \sfz -> \< ) ~ |
    gis2 r8 \! a d e  |
    fis \tenuto fis \tenuto fis \tenuto fis \tenuto e c a d,8 -> \sfz ~ |
    d2. \< r4 \! |
  }
  R1 |
  r4. a''8 -. \f r4 a4 \ff -> ~ | \break
  
  \inst "I"
  s1*0 ^\markup { "Coro Pregón 1 " }
  a4 r2. |
  \set Score.skipBars = ##t R1*9 |  \break
  a,4 \f -> r8 a8 a4 -> r |
  r8 a8 -> \bendAfter #-4 r2. |
  r2 a8 -> a -. r a8 -. |
  r4. a8 -> r a -> \bendAfter #-4 r4 | 
  r2 r8 a -> r fis ->  |
  r4 r8 a -> r fis -> r4  |
  R1*2 | \break
  
  \repeat volta 2 {
     d8 \mf -> d ->fis ( a ) r2  |
    r8 e' \f -. r e \tenuto a \tenuto a \tenuto g \tenuto g \tenuto |
    g \tenuto r8 r2. |
    R1 |
  }
  a,4 \f -> r g -> r |
  fis -> r2 g4 -> |
  fis4 -> r2. |
  r4. fis'4 -. fis8 ( e -. ) r | \break
  
  \inst "J = B"
  s1*0 ^\markup { "Brass" }
  \repeat volta 2 {
    d4 ( d c e -. ) |
    d4. \tenuto -> a8 ~ a \tenuto r4. |
    a'4 -> a -> a -> r8 a -> |
    r a -> r2. | \break 
  }
  d,4 ( d c e -. ) |
  d4. \tenuto -> a8 ~ a \tenuto r4. | \break

  \inst "K = C"
  s1*0 ^\markup { "Verso" }
  \set Score.skipBars = ##t R1*16 |
  
  \inst "L"
  s1*0 ^\markup { "Coda" }
  \set Score.skipBars = ##t R1*2
  fis'4 \f -> fis -> fis -> fis -> |
  fis4 \bendAfter #-8 -> \ff r2. ^\markup { "Timbales + snare" } |
  r2  \fermata d2 \tenuto \mf  ( ~ _\markup { "sub. rit." } |
  d1 | 
  g,4 ) ^\markup { "On signal" } \ff -> r2. |
  
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