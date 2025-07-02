\version "2.24.4"

\header {
    title = "#34 Chan Chan (La Familia: Dmi)"
        instrument = "trombone"
    composer = "by Compay Segundo"
      arranger = "arr. Ladislav Maršík"
  opus = "version 25.5.2025"
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


Trombone = \new Voice
\relative c'
{

  \set Staff.instrumentName = \markup {
    \center-align { "Trombone" }
  }
  \set Staff.midiInstrument = "trombone"
  \set Staff.midiMaximumVolume = #0.9

  \clef bass
  \key d \minor
  \time 4/4
  \tempo "Son" 4 = 160
  
     \inst "in"
      s1*0 ^\markup { "Intro" }
      R1*2 |
      g,2. a4 ~ |
      a1 |
      R1*2
      g2. a4 ~ |
      a1 |
      R1 |
      r2 \tuplet 3/2 { d4 f d } |
      g,2. a4 ~ |
      a1 | \break
      
           \inst "A1"
      s1*0 ^\markup { "De Alto Cedro" }
      R1*4 
      R1*4 ^\markup { "answer sax" }
      R1*4 ^\markup { "De Alto Cedro" }
      R1*4 ^\markup { "answer trumpet" }
      R1*4 ^\markup { "De Alto Cedro" }
      R1*4 ^\markup { "answer trombone" } \break
            
            \inst "B"
       s1*0 ^\markup { "El Carino" }
      R1*8 
      R1*8 ^\markup { "answer trumpet" } \break
                  \inst "C"
      s1*0 ^\markup { "Cuando Juanita" }
     R1*8 
      R1*8 ^\markup { "answer trombone" } \break
      
                             \inst "A2"
            s1*0 ^\markup { "De Alto Cedro" }
      R1*4 
      R1*4 ^\markup { "answer piano" }
      R1*4 ^\markup { "De Alto Cedro" }
      R1*4 ^\markup { "answer piano" } \break

                             \inst "D"
        R1*3 ^\markup { "3rd De Alto Cedro" }
	r8 a'8 ^\markup { "solo sax" } b cis d e f g \! |
	a4. f4 e8 bes a'8 ~ |
	a4. f4 e8 bes bes'8 -\tenuto ~ |
	bes4. g4 d8 e cis ~ |
	cis4. r8 r4. a8 |
	\tuplet 3/4 { d d d } f d4 c8 ~ |
	c8 c4 e4. c4 |
	beses4. f4 e'8 d cis ~ |
	cis4. r8 r2 |
	d8 e f g a4 -\staccato r4 |
	\tuplet 3/4 { r8 c, f} f g g e |
	f4. e8 r d e d |
	cis4. r8 r8 a b cis |
	d4. a'8 -\staccato \tuplet 3/4 { r f, d } |
	c4. g'8 -\staccato \tuplet 3/4 { r e c } |
	bes4. f'8 -\staccato r e d cis ~ |
	cis4. r8 r2 | \break
                             \inst "E"
                                         s1*0 ^\markup { "Guitar Solo" }
      R1*24 \break
      
         \inst "A3"
      s1*0 ^\markup { "De Alto" }
      R1*4 
      R1*4 ^\markup { "answer sax" }
      R1*4 ^\markup { "De Alto" }
      R1*4 ^\markup { "answer tr." }
      R1*4 ^\markup { "De Alto" }
      R1*4 ^\markup { "answer tb." }
      R1*3 ^\markup { "De Alto " } 
      R1 ^\markup { "rit. " }  \fermata
      d''1
      \break

      
            \chordmode {
d,1:m } ^\markup { "impro help" }
            \chordmode {|
f,1 |
g,1:m  |
a,1  |
  
            }
  
  \label #'lastPage
  \bar "|."
}

Chords =

\chords {
  \set noChordSymbol = ""
  R1*157
 
  d1:m |
  f1 |
  g1:m |
  a1  |
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Trombone
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