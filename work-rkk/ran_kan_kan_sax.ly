\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Ran Kan Kan"
  instrument = "sax"
  composer = "by Croma Latina"
  arranger = "arr. Ladislav Maršík"
  opus = "version 17.1.2023"
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
\transpose c a'
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \key d \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190

  \inst "A"
  d'4 \f -> r d -> r |
  d -> r8 c r e r c |
  d4 -> r8 c r e r c |
  d4 -> d -> d -> r |
  R1 |
  d4 -> d -> d -> r8 d -> |
  r d -> r2. | \break
  \repeat volta 2 {
    d,4 ( d c e -. ) |
    d4. \tenuto -> a8 ~ a \tenuto r4. |
    fis'4 -> fis -> fis -> r8 fis -> |
    r fis -> r2. | \break 
  }
  d4 ( d c e -. ) |
  d4. \tenuto -> a8 ~ a \tenuto r4. | \break

  \inst "B"
  s1*0 ^\markup { "Verso" }
  \set Score.skipBars = ##t R1*16 |

  d4 -> d -> d -> r |
  R1 |  \break
 
  \inst "C"
  \repeat volta 2 {
    d8 \tenuto \mf r fis ( c ) r e \tenuto r d \tenuto |
    r fis \tenuto r c \tenuto c \tenuto r4. |
    d8 \tenuto r fis ( c ) r e \tenuto r d \tenuto |
    r fis \tenuto r c \tenuto c \tenuto r4. | | \break
  }

  \inst "D"
  s1*0 ^\markup { "Ran Kan Kan" }
  d8 \tenuto r r2. |
  \set Score.skipBars = ##t R1*15 |
  
  \inst "E"
  s1*0 ^\markup { "Puente" }
  \repeat volta 2 {
    r8 a \mf ( d fis c e ) r d | 
    r fis \tenuto r c \tenuto r c ( e d ) |
    r8 a \mf ( d fis c e ) r d | 
    r fis \tenuto r c \tenuto r c ( e d ) |
    r8 a \mf ( d fis c e ) r d | 
    r fis \tenuto r c \tenuto r c ( e d ) |
  }
  
  \alternative {
    { 
      r8 a \mf ( d fis c e ) r c \tenuto ~ | 
      c4 r8 e \tenuto ~ e4 d \tenuto |
    }
    {
      r8 a \mf ( d fis c e ) r c \tenuto ~ | 
      c4 d8 \f -> d -> d -> d -> r4  |
    } 
  } \break
  
  \set Score.skipBars = ##t R1*4 |
  
  e8 ( \mp \< c e g ~ g e g a ~ |
  a1 ) \f -> | \break
  
  \inst "F"
  s1*0 ^\markup { "Reaggaeton" }
  \set Score.skipBars = ##t R1*24 |  \break
  
  \inst "G"
  s1*0 ^\markup { "Petas" }
  \repeat volta 2 {
    a2 \f -> fis8 ( \> d a  b \sp \< ) ~ |
    b1 |
    r2. \! r8 gis8 -> \mf ~ |
    gis2. \sp \< r4 \f |
  }
  R1 |
  r4. a8 -. \f r4 d4 \ff -> ~ | \break
  \inst "H"
  s1*0 ^\markup { "Coro Pregón 1 " }
  d4 r2. |
  \set Score.skipBars = ##t R1*9 |  \break
  a4 \f -> r8 a8 a4 -> r |
  r8 b8 -> \bendAfter #-4 r2. |
  r2 a8 -> a -. r a8 -. |
  r4. b8 -> r b8 -> \bendAfter #-4 r4 | 
  R1 | \break
  \repeat volta 2 {
    d,8 \mf \tenuto \< d \tenuto fis \tenuto a \tenuto c -> \f ( b ais a \tenuto ) \sp \< ~  |
    a1 |
    R1 \! |
    R1 |
  }
  b4 \f -> r a -> r |
  g -> r4 r8 f -> r e8 -> |
  R1 | \break
  \inst "I"
  s1*0 ^\markup { "Coro Pregón 2 " }
  a1 \tenuto -> ~ |
  a1 \trill |
  \set Score.skipBars = ##t R1*8
  
  d4 \f -> d -> d -> r | \break

  \inst "J = C"
  \repeat volta 2 {
    r4. d8 -. \f r d e -. r |
    a4 -> a -> a8 a -. r4 |
    r4. d,8 -. r d e -. r | 
    a4 \tenuto -> ( a8 a ) g a -. r8 a8 -> \bendAfter #-4 | \break
  }
  r4. d,8 -. \f r d e -. r |
  
  \inst "K"
  s1*0 ^\markup { "Verso + Pregón" }
  a2 \tenuto -> r2 |
  \set Score.skipBars = ##t R1*15
  
  \inst "L"
  s1*0 ^\markup { "Coda" }
  \set Score.skipBars = ##t R1*2
  a4 \f -> a -> a -> a -> |
  s1*0 ^\markup { "Triplets" }
  R1 |
  d,1 |
  a'4 \ff -> r2. |
  
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