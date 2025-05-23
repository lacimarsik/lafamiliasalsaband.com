\version "2.24.2"

% Sheet revision 2022_09

\header {
  title = "#32 Me Quedo Contigo (Ami)"
  instrument = "trumpet"
  composer = "by Leoni Torres"
  arranger = "arr. Ladislav Maršík"
  opus = "version 20.11.2024"
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
\transpose c d % We play in Ami
\relative c'' {
  \set Staff.instrumentName = \markup {
    \center-align { "Tr. in Bb" }
  }
  \set Staff.midiInstrument = "trumpet"
  \set Staff.midiMaximumVolume = #1.0

  \key g \minor
  \time 4/4
  \tempo "Medium Salsa" 4 = 180
  
    s1*0 ^\markup { "Intro Guitar + Piano (rubato)" }
  \inst "in1"
      R1*8
      
      
        \inst "in2"
          s1*0 ^\markup { "Intro Sax (rubato)" }
      R1*7
      
      r2 d,8 c bes a  \break
        \inst "in3"
                s1*0 ^\markup { "Intro Brass (a tempo)" }
      bes4. d g4~ |
      g8 d4. d8 c bes a | 
      bes4. es g4~ |
      g8 es4. es8 d c bes ~ | 
      bes4. d f4~ |
      f8 d4. d8 c bes a ~ | 
      a4. c f4~ |
      f8 c4. d8 c bes a | \break
     s1*0 ^\markup { "Verso 1 (rhythm)" }
     \inst "A"
      bes4 r2. | 

     R1*7 
    s1*0 ^\markup { "Piano accents" }
     R1*7
     
           
           r4. d8 bes' a g f | \break
         s1*0 ^\markup { "Chorus 1 & 2 " }
         \segno
        \inst "B1,2"
           bes8 -> r r2. |
           R1*15 \break
                 s1*0 ^\markup { "Oh oh oh 1 & 2" }
        \inst "C1,2"
        R1*7
        ^\markup { "                                   to coda" }
          r4. f8 d' c bes a | \break
          
            \inst "in4"
                s1*0 ^\markup { "Intro Brass" }
      bes4. d g4~ |
      g8 d4. d8 c bes a | 
      bes4. es g4~ |
      g8 es4. es8 d c bes ~ | 
      bes4. d f4~ |
      f8 d4. d8 c bes a ~ | 
      a4. c f4~ |
      f8 c4. d8 c bes a | \break
          
          s1*0 ^\markup { "Verso 2 (suave)" }
                  \inst "A2"
           R1*3
           r4 c2. |
                             d1 |
                             R1 | 
                             a4. \accent g \accent f4 ~ |
                             f4.        f8 d' c bes a | \break
                             
                                 s1*0 ^\markup { "Piano accents" }
bes8 r r2. |
     R1*6
               r4. f8 d' c bes a    ^\markup { " D.S. Al Coda" } | \break
   
                             
         s1*0 ^\markup { "Play if no trumpet" }
         \coda        
        r2. r8   d'8 |
        
                \repeat volta 2 {
        r  bes r  g4. r4 |
     r8 d g bes d4. es8 |
     r bes r g4. r4 |
     r8 es g bes es d c d |
     r8 bes  r f4. r4 |
                }
                
                \alternative {
                  {
     r8 f8 f f bes4 -- d8 c |
     r a4 \accent c4 \accent c8 c4 -- |
     r8 bes4 \accent c8 d4 -- r8 d |
                  }{ 
                  r8 f,8 f f bes4 -- d4 -- |
                  f \accent r8 f4 \accent  f8 f4 \accent
                  r f \accent ges \accent r |
                  r g4 \bendAfter #-4 r2 ^\markup { "FINE" } |
                  }
        }
           
                    s1*0 ^\markup { "Bomba" }
           R1*7
           
                               s1*0 ^\markup { "Y Si Tu Me Quieres" }
           R1*15 ^\markup { "                   Dal Coda Al FINE" }
           
           
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \Trumpet
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