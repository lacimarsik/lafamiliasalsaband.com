\version "2.24.0"

% Sheet revision 2022_09

\header {
    title = "#27 Conga"
        instrument = "sax"
    composer = "Gloria Estefan"
      arranger = "arr. Ladislav Maršík"
  opus = "version 27.3.2024"
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


AltoSax = \new Voice
\transpose c a
\relative c' {
    \set Staff.instrumentName = \markup {
        \center-align { "Sass. in Eb" }
    }

    \key e \minor
    \time 4/4
    \tempo "Allegro" 4 = 220
    
    \partial 1
    d2 \ff -> dis4. -> e8 -. -> |
    
    
    s1*0 ^\markup { "Chorus 1" }
  \inst "C1"
    R1*8 
    R1*7 ^\markup { "Intro Piano" }
    r2. r8 e -^ \ff \bendAfter -4|
    R1*8 ^\markup { "Percussions 1" }
    
    s1*0 ^\markup { "Chorus 2" }
  \inst "C2"
    R1*8 
    R1*15 ^\markup { "Percussions 2" }
    d2 -> dis4. -> e8 -. -> | \break
        s1*0 ^\markup { "Brass 1" }
  \inst "B1"
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
        r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    }
            s1*0 ^\markup { "Verso 1" }
  \inst "V1"
    r8 e' \tenuto -> \bendAfter #-6 r4 r1. |
R1*4
    r2 e,4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    
    
    \repeat volta 2 {
        R1 |
        r2 r8 e -. -> r d -. -> |
        R1 |
        r2 r4. d8 -. -> |
    
    \alternative {
        {
            R1 |
            R1 |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        }
        {
            r1 r2. r8 e \tenuto -> \bendAfter #-6 | \break
        }
     }
    }
    
    \set Score.skipBars = ##t R\breve*3 ^\markup { "Percussions 3" }
    
    r1 b'8 \ff -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | 
    
        s1*0 ^\markup { "Chorus 3 + Brass" }
  \inst "C3"
    r1 r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> | \break
    
            s1*0 ^\markup { "Brass 1" }
  \inst "B1"
    r1  r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    
            s1*0 ^\markup { "Verso 2" }
  \inst "V2"
  R1*6
    r2 e4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
    R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e -! -^  ^\markup { "Stop" } |
            r1 r2. r8 e -. -> | \break
        }
    }
    \repeat volta 2 {
        r1 ^\markup { "Intro Piano + Bass + Brass" } r2 r8 e \ff -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    }
    \alternative {
        {
            r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
        }
        {
            r1 r2. r8 e' \tenuto -> | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Piano solo" }
    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
            s1*0 ^\markup { "Chorus 4 + Brass" }
  \inst "C4"
    r1  r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    R\breve | \break
    
                s1*0 ^\markup { "Brass Bridge" }
  \inst "D"
    r8 d, ( \f \< e g a b d e -. -> ) \ff r2 r4 b'8 \tenuto b \tenuto |
    b4 \> -> -. a8 a \tenuto -. r fis -. r d -. \mf r1 |
    r8 e, ( \< eis fis ~ \tenuto ) fis a ( b  d ~ \tenuto ) d4 r8 a ( b \tenuto d dis e \tenuto -. \f ) |
    r2 a4 -. -> c4 -. -> d4 \tenuto -> ~ d8 ( a -. ) r2 | \break
    r4. b,8 ( \mf \< e -. ->  ) r fis -. -> r g \f -. -> r fis ( e -. -> ) r d -. -> r fis -. -> |
    r d -. -> r4 r8 a -. \mf d -. fis -. \tuplet 3/2 { g4 ( [ \tenuto \ff fis \tenuto f \tenuto \> ] } e8 d -. \f ) r fis -. -> |
    r d -. -> r b ( d4 -. -> ) r d8 -. -> r e fis -. -> r d -. -> r e \sff -! -^ |
    r4. e8 -! -^ r4. e8 -! -^ e -! -^ e -! -^ e -! -^ r r4. e'8 \fff \bendAfter #-8 -! -^ | 
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Solo Sax" }
    r1 d,2 \f -> dis4. -> e8 -. -> | \break
    
                s1*0 ^\markup { "Chorus 5 + Brass" }
  \inst "C5"
    \repeat volta 2 {
        r1  r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> |
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> |
    }
    
    s1*0 ^\markup { "Solo Brass (Trumpet + Trombone)" }
    R1*32 \break

            s1*0 ^\markup { "Brass 3 + Piano" }
  \inst "B3"
    r1  r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    r8 e' \tenuto -> \bendAfter #-6 r4 r2 r r8 e, -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |

    r1 ^\markup { "Coda" } r2 r4 e' -! -^ |

  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \AltoSax
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