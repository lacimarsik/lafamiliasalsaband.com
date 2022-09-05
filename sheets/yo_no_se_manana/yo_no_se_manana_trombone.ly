\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Yo No Se Mañana"
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

  \clef bass
  \key f \major
  \time 4/4
  \tempo "Medium-Fast Salsa" 4 = 190
  
  R1 ^\markup { "Piano" } |
  \inst "A"
  \set Score.skipBars = ##t R1*16
  
  \set Score.skipBars = ##t R1*15 ^\markup { "Verse 1" }

  r2 r4 f4 -\p ~ |
  s1*0 ^\markup { "Verse 2 & 3" }
  \inst "D"
  \inst "B"
  \repeat volta 2 {
    f1 ~ |
    f1 |
    r1 |
    g1 ~ |

    g1 ~ |
    g2 a2 |
    g1 ~ |
    g2 r2 |

    f1 ~ |
    f1 |
    
    \set Score.skipBars = ##t R1*5
    
    c4 _\markup { \italic "cresc." } d4 f2 |
    s1*0 ^\markup { "Chorus" }
    \inst "E"
    \inst "C"
    f4 -\accent -\f  r4 r2 |

    r1 |
    r4. f4. -> f8 -. r8 |

    r1 |
    r4. f4. -> f8 -. r8 |

    R1 |
    c'1 \sp ( \< ~ |
    c1 |

    bes8 ) \> r4 \! g8 \mp \< g8 g8 \! -. r4 |
    r4. g8 \< g8  \! g8 -. r4 |
    r4. g8 \< g8  \! g8 -. r4 |

    r4. g8 \< g8 \! g8 -. r4 |
    r4. f8 \< f8 \! f8 -. r4 |
    r4. f8 \< f8 \! f8 -. r4 |

    r2 e4. \tenuto \mf d8 \tenuto ~ |
    d4 r2. |

    \set Score.skipBars = ##t R1*4
  }
  \alternative {
    {
      \set Score.skipBars = ##t R1*3
      r2 r4 f4 -\p \laissezVibrer |
    }
    {
      r4. d'8 \mp \tenuto ~ d4 c8 r |
      r4. d8 \tenuto ~ d4 c8 r |
      r4. d8 \tenuto ~ d4 c8 r |
      c4 -- -\f ( d -- g, -- bes -- ~ |
    }
  }
  \inst "F"
  bes ^\markup { "Bridge 1" } ) r4 r2 |
  
  \set Score.skipBars = ##t R1*6
  
  c4 -- ( d -- g, -- bes -- ~ |
  bes ) r4 r2 |
  
  \set Score.skipBars = ##t R1*3
  
  r4. g8 -. -\mp r g -. g4 -- ~ |
  g4. g8 -. r f g4 -- ~ |
  g4. g8 -\mf -> ~ g4 r |
  R1 | \break
  r2. c4 -\f ( |
  c d f d |
  f4. f8 -. ~ f4 ) r |
  R1 |
  r2. c4 ( |
  c d f d |
  f4. f8 -. ~ f4 ) r |
  R1 |
  
  \repeat volta 2 {
    \set Score.skipBars = ##t R1*7 ^\markup { "Coro Pregón 1" }
  }
  \alternative {
    {
      R1 | \break
    }
    {
      c,4 -- -\mf d -- f -- a -- |
    }
  }
  \repeat volta 2 {
    \inst "G"
    g8 -- ^\markup { "Bridge 2" } g4 -. g8 -> r fis ( g g -. ) |
    r g -. r fis ( g g -. ) r g -> |
    r fis ( g g -. ) r g -> r4 |
  }
  \alternative {
    {
      c,4 -- d -- f -- a -- |
    }
    {
      c,4 -\f -- d -- f -- g -- |
    }
  }
  r8 a4 -> r8 r2 |
  \set Score.skipBars = ##t R1*7 ^\markup { "Coro Pregón 2" }
  \set Score.skipBars = ##t R1*8

  g'8 \< \tenuto  ^\markup { "Yo no se, Yo no se" } \mp g \tenuto g \tenuto \! g \tenuto r g \< \tenuto g \tenuto g \tenuto |
  g8 \tenuto \! g \tenuto r4 g8 \tenuto g \tenuto r4 |
  f8 \< \tenuto f \tenuto f \tenuto \! f \tenuto r f \< \tenuto f \tenuto f \tenuto |
  f8 \tenuto \! f \tenuto r4 f8 \tenuto f \tenuto r4 |
  g8 \< \tenuto  g \tenuto g \tenuto \! g \tenuto r g \< \tenuto g \tenuto g \tenuto |
  g8 \tenuto \! g \tenuto r4 g8 \tenuto g \tenuto r4 |
  r4. f8 \f  -> ~ f4 r4 |
  R1 |
  \inst "H"
  r2. ^\markup { "Chorus" } d4 \f  -> |
  R1*6
  
  c4 \f -- ( d -- g, -- bes -- ~ |
  bes1 ~ |
  bes1 ) |
  R1 |
  c4 -- ( d -- f, -- a -- ~ |
  a1 ~ |
  a1 ) |

  R1 |
  c4 -- ( d -- g, -- bes -- ~ |
  bes8 ) r8 r2. |
  R1 |
  bes4 \tenuto \f c4 \tenuto  r2 |
  
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