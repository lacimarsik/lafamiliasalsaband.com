\version "2.24.4"

\header {
    title = "#17 Baila Mi Gente (Latin Soul: Ami)"
        instrument = "trumpet"
    composer = "by Poncho Sanchez"
      arranger = "arr. Lisa Nosková & Ladislav Maršík"
  opus = "version 28.8.2024"
    copyright = "© Latin Soul 2024"
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
\relative c'' {
  \set Staff.instrumentName = \markup {
    \center-align { "Tr. in Bb" }
  }
  \set Staff.midiInstrument = "trumpet"
  \set Staff.midiMaximumVolume = #0.9

  \key a \minor
  \time 4/4
  \tempo "Cha Cha" 4 = 120

    s1*0 ^\markup { "Intro Piano + Bass" }
    \inst "in1"
    R1*8 \break
   
   s1*0 ^\markup { "Trumpet start" } 
    \inst "in2"
   
    d1 ~ |
    d4. e8 d c a d ~ |
    d4. e8 d c a c ~ |
    c4 r4 r8 a b c |
    d1 ~ |
    d4. e8 d c a d ~ |
        d4. e8 d c a c ~ |
        c4 r2. | \break
        
    s1*0 ^\markup { "Coro 1: Baila Mi Gente (no trumpet)" } 
    \inst "A1"
        R1*8 
      s1*0 ^\markup { "Verso 1" } 
    \inst "B1"
   R1*8 \break
   
       s1*0 ^\markup { "Coro 2: Baila Mi Gente (with trumpet)" } 
    \inst "A2"
   R1 |
   r8 a b c ~ c e, g a |
   gis4. g2 b8 ~ |
   b4. a8 ~ a2 |
    R1*2 
    
    g4 g r8 f8 ~ f e ~ |
    e4 r2. |
          s1*0 ^\markup { "Verso 2" } 
    \inst "B2"
    R1*8 \break
           s1*0 ^\markup { "Coro 3: Baila Mi Gente (with trumpet)" } 
    \inst "A3"
    R1 |
    r8 a b c ~ c e, g a |
    gis 4. g2 b8 ~ |
    b4. a8 ~ a2 |
    R1*2 
    g4 g r8 f8 ~ f e ~ |
    e4 r2 .|
    R1 ^\markup { "Break 1" } |
    r2. r8 e8 ~ | \break
    
               s1*0 ^\markup { "Trumpet Interlude" } 
    \inst "C"
    e8 a b c b a ~ a c, ~ |
    c f g a g f ~ f e ~ |
    e a b c b a ~ a c, ~ |
    c f g a g f ~ f e ~ |
    e a b c b a ~ a c, ~ |
    c f g a g f ~ f e ~ |
    e a b c b a ~ a c, ~ |
    c f g a g f ~ f r | \break
  
  \repeat volta 2 {
          \chordmode {
   a2:m _\markup { "Solos ad lib." }  g2   |
      f2 e2 | \break
      }
  }
      
    R1*16 \fermata ^\markup { \column { \line { "Forma: Vacila Mi Tambor, opt. SOLO 2, Vacila Mi Tambor" } } } \break
    
    s1*0 ^\markup { "Outro: Coro" } 
\inst "out = A"

\repeat volta 2 {
  R1 |
r8 a b c ~ c e, g a |
   gis4. g2 b8 ~ |
   b4. a8 ~ a2 |
    R1*2 
    
    g4 g r8 f8 ~ f e ~ |
    e4 r2. |

}

e4 e8 e r e e e |
e e e e e r e e | r4 a
    
  \label #'lastPage
  \bar "|."
}

Chords =
\transpose c d'
\chords {
  \set noChordSymbol = ""

  R1*65

   a2:m g2 |
      f2 e2 |

      
     
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Trumpet
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