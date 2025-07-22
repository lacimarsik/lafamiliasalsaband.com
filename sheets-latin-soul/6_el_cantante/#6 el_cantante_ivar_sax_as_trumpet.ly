\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#6 El Cantante (Latin Soul: Gmi)"
  instrument = "sax as trumpet"
  composer = "by Hector Lavoe y Ruben Blades"
  arranger = "arr. Ladislav Maršík"
  opus = "version 16.10.2024"
  copyright = "© Latin Soul"
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
\transpose c a,
\relative c'' {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #1.0

  \key g \minor
  \time 4/4
  \tempo "Medium Salsa" 4 = 180
  
  s1*0 ^\markup { "Intro" }
     \inst "A"
     
     d4  \mf -. g8 fis r d r f |
     r e r c r g r bes |
     c16 bes c8 ~ c2. ~ |
     c2. r4 |
    c,4 -. f8 e r c r f |
    r e r c ~ c4 r |
    e4 -. a8 g r e r a |
    r g r e ~ e4 r |
    c4 -. f8 e r c r f |
    r e r c ~ c4 r |
    
     g'4 \f -. a8 bes r c d4 -. |
     r2 d, -> |
       s1*0 ^\markup { "Accents" }
          \inst "B1"
     R1 |
     r2 \tuplet 3/2 { d'8 \f c b } c4 ~ |
     c1 ~ \> |
     c1 \p |
     
     R1*4 | \break
     
            s1*0 ^\markup { "Verso 1" }
          \inst "C1"
     R1*11
     r8 a, \mp ( bes b c c' a es ~ |
     es1 |
     d1 ) |
     R1*2 
    
    s1*0 ^\markup { "Y canto a la vida" }
    bes'1 \mp |
    a1 |
    a1 |
    g1 |
    g2 r2 |
    r8 g \mf e f fis c' -> a bes ~ |
    bes1 |
    b1 |
        es,1 \mp |
    es |
    d |
    bes2 r2 |
    R1*2 |
           s1*0 ^\markup { "Accents" }
          \inst "B2"
    g'4 \mf -. r8 des4 -. r8 c4 -- ~ |
    c2. r4 |
        g'4 -. r8 des4 -. r8 c4 -- ~ |
    c4 r  \tuplet 3/2 { d'8 \f c b } c4 ~ |
     c1 ~ \> |
     c2 \p r |
      g4 \mf -. r8 des4 -. r8 c4 -- ~ |
    c2. r4 | 
    g'4 -. ^\markup { "In original there is 1 more time accents" } r8 des4 -. r8 c4 -- ~ |
    c2. r4 | \break
     
       s1*0 ^\markup { "Verso 2" }
     \inst "C2"
     R1*3
     
     e'4 \f ( cis a e |
     c'1 ~ \> |
     c2 ) \p r |
     r2 bes,8 ( c cis d ) |
     r d' r d, es'4 ( d -. ) |  \break
     f,1 ~ |
     f1 |
     g 1 ~ |
     g1 |
     bes  (|
     c |
     bes |
     b ) |
     s1*0 ^\markup { "Y nadie pregunta" }
    R1*7 |
    as4 ( \mf g -. ) es' ( d -. ) |
    R1 |
    c8 \mf c r c f4 ( es -. ) |
    R1 |
    bes8 \mf bes r bes es4 ( d -. ) |
    R1*2 
               s1*0 ^\markup { "Accents" }
          \inst "B3"
        f4 -. r8 f4 -- r8 e4 -- ~ |
    e2. r4 |
             f4 -. r8 f4 -- r8 e4 -- ~ |
    e2. r4 |
            f4 -. r8 f4 -- r8 e4 -- ~ |
    e2. r4 |
    R1*2 |
          
       s1*0 ^\markup { "Verso 3 con Piano" }
     \inst "C3"
     R1*32 \break
     
                              s1*0 ^\markup { "Intro Del Coro" }
          \inst "D1"
     
     \tuplet 3/2 { c,4 -> \f c c } cis4. d8 ~ |
     d2 r4 fis8 a |
          s1*0 ^\markup { "Trumpet" }
     es'4 -. d8 a r bes r g  |
     R1 |
          \tuplet 3/2 { g4 -> \f g g } gis4. a8 ~ |
     a2 r4 fis8 a |
           s1*0 ^\markup { "Sax" }
     c4 -. c8 es r d r bes  |
     r4. d8 -> d4 -> r | \break
     
                                   s1*0 ^\markup { "Coro y Metales" }
                                        \inst "E"
     R1*4
           s1*0 ^\markup { "Trumpet" }
     r4. d,8 \< r g r bes \f |
     d4 -> c2. -> |
     
     R1*3 ^\markup { "y solo impr." }
         
     R1*3
           s1*0 ^\markup { "Trumpet" }
     r4. d,8 \< r g r bes \f |
     d4 -> c2. -> |
     
     R1*3 ^\markup { "y solo impr." } 
     
                                        s1*0 ^\markup { "Coro y Pregón" } 
                                        \inst "F"
     R1*28  \fermata ^\markup { \column { \line { "Forma:4Coro3Pregón,SOLO" } \line { "Intro Del Coro D2 = D1" } \line { "4 Coro 3 Pregón, Accents B4" } } } \break
   
            \chordmode {
   R1*3 _\markup { "PUENTE" }
   r2.
 c'8:m c':m 
   R1 _\markup { "Start solo" } |
d'4. d'4. d'4 ~ |
d'1  |
g'1:m  |
c'1:m |
d'1 |
d'1 |
g'1:m |
      }
      
      
     \break
          \inst "B4"
        g4 \mf -. r8 bes4 -. r8 c4 -- ~ |
    c2. r4 |
             g4 -. r8 bes4 -. r8 c8 r |
             g8 \mf a bes c d f e4 ~ | 
     e1 ~ |
     e2 r |
            g,4 -. r8 bes4 -. r8 c4 -- ~ |
    c2. r4 | 
                g4 \f -> r8 bes4 -> r8 c4 -> ~ |

          
     
     
     
     
  
  \label #'lastPage
  \bar "|."
}

Chords =
\transpose c a,
\chords {
  \set noChordSymbol = ""
  R1*183

  c1:m |
  d1 |
  d1 |
  g2.:m c4:m |
  c1:m |
  d1 |
  d1 |
  g1:m |
  c1:m |
  d1 |
  d1 |
  g1:m |
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Sax
    }
  >>
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