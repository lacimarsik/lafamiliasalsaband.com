\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#40 Familia Intro"
  instrument = "alto sax"
  composer =  "by Luca Colella"
  arranger = "arr. Ladislav Maršík"
  opus = "version 22.4.2025"
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
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "A. Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \key e \minor
  \time 4/4
   \tempo "Fast Salsa" 4 = 190
  
    s1*0 ^\markup { "Brass Intro, 2va with band" }
  \inst "in"
  
   
 \repeat volta 2 {
   e4. d8 r4 e8 r |
 g4. e8 r g r e |
 r8 g4. e8 r r d' |
cis4. b8 r4. cis8 |
b4. a8 r4. e8 |
g g e g e g e g |
d' r d cis r b4. ~ |
b1 | \break
 } 

e,1 ~ |
e |
e' ~ |
e |
e ~ |
e ~ | 
e ~ |
e4 \bendAfter #-4 r2. |

    s1*0 ^\markup { "Piano montuno" }
  
R1*8 \break
    s1*0 ^\markup { "Baila La Familia" }
  \inst "A"


\repeat volta 2 {
  

 
 e,4. g4. -- ~ g4 ~ |
 g2 e4 -. g -. |
 d'8 d r d r4 d 8 d |
 r d r2.  |
 b8 a g a ~ a g bes a |
 g a ~ a4 r g |
 b8 a g b ~ b2 ~ |
 b2 b8 a g fis | \break
 
}

    s1*0 ^\markup { "Rap" }
    \inst "B"
R1*8 \break
\repeat volta 2 {
    s1*0 ^\markup { "Bum-Bum" }
    \inst "C"
b8 r4 b8 r2 |
r2. c8 r |
b8 r4 b8 r4 b8 b ~ |
b2 r4 c8 r  |
b8 r4 b8 r2 | 
r2. c8 r |
b8 r4 b8 r4 b4 ~ |
b2 r2 | \break
}
  s1*0 ^\markup { "Carnaval" }
    \inst "D"
\repeat volta 2 {
  e8 e r4 c8 c r b  |
  r b, r dis r fis r a |
  b c b c b c b c |
  b c b e ~ e4 r | 
}

    s1*0 ^\markup { "Hua" }
    \inst "E"
R1*8 \break

  s1*0 ^\markup { "La Candela" }
    \inst "F"
e,4 r g r8 c, | 
  r e r g r c, cis r | 
  d4 r fis4 r8 e |
  r e r g r e r4 | 
  e4 r g r8 c, | 
  r e r g r c, cis r | 
  d4 r fis4 r8 e |
  r e r g r e r4 | \break


  s1*0 ^\markup { "Rumba break 1" }


  d4 r8 c4 r8 b4 ~ |
  b1 |
  dis1 |
  b'1 | \break
  
  s1*0 ^\markup { "Aqui se encende la candela" }
    \inst "G"
  
R1*8 \break

s1*0 ^\markup { "La Candela 2" }
    \inst "H"
\repeat volta 2 {
\grace {g8 a  bes } c8 c r c g g r e |
r e r  a  r bes  a4 ~ |
a2 g4 r  |
R1 | \break
}

  s1*0 ^\markup { "Rumba break 2" }
  d4 r8 c4 r8 b4 ~ |
  b1 ~ |
  b |
  b |
  e4 e4 r2 |
 
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