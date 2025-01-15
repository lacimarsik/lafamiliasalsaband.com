\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "Micaela"
  instrument = "alto sax"
  composer = "by Sonora Carruseles"
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

AltoSax = \new Voice
\transpose c a'
\relative c  {
    \set Staff.instrumentName = \markup {
        \center-align { "Sax" }
    }
    
      \clef treble
  \key c \major
  \time 4/4
  \tempo "Slower Salsa" 4 = 175
    	
    \set Score.skipBars = ##t R1*4 ^\markup { "Hu-Ha" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Percussions" } \break

    r4 c8 ^\markup { "Trumpets" } \p \< c c4 \tenuto c8 \! \mf c |
    bes8 -. r bes ( d -. ) r e -. r c \> \accent ~ |
    c8 \mp r r2. |
    R1 |
    r8 c16 \mp c c8 c  \< c4 \tenuto c8 \! \mf c |
    bes8 -. r bes ( d -. ) r e -. r c \> \accent ~ |
    c8 \mp r r2. |
    R1 | \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }

    R1 ^\markup { "Si senor" } 
    
    b8 \f \tenuto c \tenuto d \tenuto e \tenuto f4 \tenuto e8 \tenuto \accent e \tenuto \accent \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }
    
    R1 ^\markup { "Si senor" } 
    
    b8 \f \tenuto c \tenuto d \tenuto e \tenuto f4 \tenuto e8 \tenuto \accent e \tenuto \accent \break
    
    \set Score.skipBars = ##t R1*16 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*22 ^\markup { "Piano solo" } \break
    
    \set Score.skipBars = ##t R1*2 ^\markup { "Piano solo END" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Hu-Ha" }
    
    g16 \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    
    \repeat volta 4 {
        es2 ^\markup { "Trumpets 1" } \mp \< ~ es8 ( d -. \mf  ) r c \tenuto |
        r g \< \tenuto c \tenuto d \tenuto es \f \> \tenuto d \tenuto c \tenuto a \mf \tenuto |
    }
        \alternative { 
          {
            r8 d -. \f fis \tenuto ( fis \tenuto fis \tenuto ) r r d -. |
            fis \tenuto ( fis \tenuto fis \tenuto ) r fis \tenuto ( fis \tenuto ) r4 |  \break
          }
          {
            r8 ^\markup { "Trumpets 1 END" } d -. \f fis \tenuto ( fis \tenuto f \tenuto ) r r d -. |
            fis \tenuto ( fis \tenuto f \tenuto ) r fis2 \accent \bendAfter #4  |
          }
        } 
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela" } \break
    
    \repeat volta 2 { r8 ^\markup { "Trumpets 2" } bes, ( a g ) a4 -. g4 -. |
        g e ~ e r |
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
    } \break

    \repeat volta 2 { r8 bes'' ( a g ) a4 -. g4 -. |
        g e ~ e r |
    }
    \alternative {
        {
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
        }
        {
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
        }
    }
    a1 |  \break
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela + Trumpet" } \break
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 3" } b, ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    \alternative {
    {    r8 b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    {    r8 b' ( c d f4 e8 e | \break
     e2 ) \bendAfter #-5 r2 |
    }
    }
    
    \set Score.skipBars = ##t R1*7 ^\markup { "Hu-Ha + Piano change" }
    
    g,16 ^\markup { "Trumpets 4" }  \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    c2 \bendAfter #-5 r2 |
    
    
    \set Score.skipBars = ##t R1*6 ^\markup { "Montuno" }
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 5" } b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    \alternative {
    {
          r8 b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    {
          r8 b ( c d f4 e8 e |
    e2 ) \bendAfter #-5 r2 |
    }
    }
    
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