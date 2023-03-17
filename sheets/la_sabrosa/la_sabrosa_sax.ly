\version "2.24.0"

% Sheet revision 2022_09

\header {
  title =  "La Sabrosa"
  instrument = "sax"
  composer = "by Fernando Sosa & Massimo Scalici"
  arranger = "arr. Luca Colella"
  opus = "version 22.2.2023"
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

  \key d \minor
  \time 4/4
  \tempo "Slower Salsa" 4 = 180
  
  s1*0 \set Score.skipBars = ##t R1*18 ^\markup { "Intro piano" } \fermata
  \inst "A"
  
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Piano montuno" }
  s1*0 \set Score.skipBars = ##t R1*4 ^\markup { "Salsa" }
  s1*0 
  ^\markup { "Brass" }
  
  \break
  \inst "B"
  R1 | % 2
    r8 \stemUp    b8 [ \stemUp cis8 \stemUp d8 \stemUp e8 \stemUp f8
    \stemUp g8 \stemUp a8 ] | % 3
    r8 \stemUp f8 r2 r4 | % 4
    r8 \stemUp cis8 [ \stemUp c8 \stemUp cis8 \stemUp e8 \stemUp cis8
    \stemUp e8 \stemUp d8 ] | % 5
    r8 \stemUp f8 r2 r4 | % 6
    r8 \stemUp b,8 [ \stemUp cis8 \stemUp d8 \stemUp e8 \stemUp f8
    \stemUp g8 \stemUp a8 ] | % 7
    r8 \stemUp f8 r2 r4 | % 8
    r8 \stemUp cis8 [ \stemUp c8 \stemUp cis8 \stemUp e8 \stemUp cis8
    \stemUp e8 \stemUp d8 ] | \break  % 9
     \inst "C"
    \stemUp f8 [ ^ "Trumpets"  \stemUp e8 \stemUp f8 \stemUp a8 ] r8 \stemUp f8 r8
    \stemUp g8 | 
    r8 \stemUp f8 \stemUp e8 \stemUp d8 \stemUp cis8 \stemUp e8 \stemUp
    g4 ~ | % 11
    \stemUp g4 r4 r2 | % 12
    r2 r8 \stemUp f8 [ \stemUp g8 ] r8 | % 13
    \stemUp a4. \stemUp g4. r4 | % 14
    \stemUp g4. \stemUp f4. r4 | % 15
    \stemDown e'8 r8 \stemUp a,8 r8 \stemDown cis4. \stemDown d8 | % 16
    r4. \stemDown d4 r8 r4 | \break % 17
    
      
    \inst "D"
    r2 ^ "Coro 1" r4 r8 \stemUp g,8 | % 18
    r8 \stemUp e8 r8 \stemUp bes'8 [ \stemUp a8 \stemUp g8 ] \stemUp a4
    | % 19
    r8 \stemUp g8 [ \stemUp fis8 \stemUp g8 \stemUp bes8 \stemUp g8
    \stemUp bes8 \stemUp a8 ] | 
    r8 \stemUp f8 r4 r8 \stemUp f8 [ \stemUp g8 \stemUp a8 ] | % 21
    \stemUp a4. \stemUp g4. r4 | % 22
    \stemUp g4. \stemUp f4. r4 | % 23
    R1 | % 24
    \stemUp f8 r8 \stemUp f8 [ \stemUp f8 ] r2 | \break % 25
          \inst "E"
    r2 ^ "Solo Cantante 1" r4 r8 \stemUp e8 | % 26
    r8 \stemUp e8 r8 \stemUp f8 [ \stemUp g8 \stemUp e8 \stemUp f8
    \stemUp g8 ] | % 27
    r8 \stemUp e8 r2 r4 | % 28
    r8 \stemUp f8 [ \stemUp g8 \stemUp a8 ] r8 \stemUp f4 r8 | % 29
    \stemUp a4. \stemUp g4. r4 | 
    \stemUp g4. \stemUp f4. r4 | % 31
    r8 \stemUp a8 [ \stemUp g8 \stemUp f8 \stemUp g8 \stemUp a8 ] r8
    \stemUp f8 | % 32
    r8 \stemUp g8 r8 \stemUp a8 r4 \stemDown d4 ~ | % 33
    \stemDown d4 r4 r2 | % 34
    r8 \stemUp e,8 r8 \stemUp f8 [ \stemUp g8 \stemUp e8 \stemUp f8
    \stemUp g8 ] | % 35
    r8 \stemUp e8 r8 \stemUp e2 r8 | % 36
    r8 \stemUp f8 [ \stemUp g8 \stemUp a8 ] r8 \stemUp f4 r8 | % 37
    \stemUp a4. \stemUp g4. r4 | % 38
    \stemUp g4. \stemUp f4. r4 | % 39
    r8 \stemUp a8 [ \stemUp g8 \stemUp f8 \stemUp g8 \stemUp a8 ] r4 |
    \stemUp a8 r8 \stemUp a8 [ \stemUp a8 ] r4 \stemUp a4 ~ | \break % 41
            \inst "F"
    \stemUp a4 ^ "Coro 2"  r4 r2 | % 42
    r4 r8 \stemUp f8 [ \stemUp e8 \stemUp d8 ] \stemUp e4 | % 43
    r8 \stemUp cis8 [ \stemUp c8 \stemUp cis8
    \stemUp e8 \stemUp cis8 \stemUp e8 \stemUp d8 ] | % 44
    r8 \stemUp f4 r4 \stemUp f8 [ \stemUp g8 \stemUp a8 ] | % 45
    \stemUp a4. \stemUp g4. r4 | % 46
    \stemUp g4. \stemUp f4. r4 | % 47
    R1 | % 48
    \stemUp f8 r8 \stemUp f8 [ \stemUp f8 ] r2 | \break % 49
    
        \inst "G"
    R1 ^ "Solo Cantante 2" | 
    r8 \stemUp e8 r8 \stemUp f8 [ \stemUp g8 \stemUp e8 \stemUp f8
    \stemUp g8 ] | % 51
    r8 \stemUp e8 r2 r4 | % 52
    r8 \stemUp f8 [ \stemUp g8 \stemUp a8 ] r8
    \stemUp f4 r8 | % 53
    \stemUp a4. \stemUp g4. r4 | % 54
    \stemUp g4. \stemUp f4. r4 | % 55
    r8 \stemUp a8 [ \stemUp g8 \stemUp f8 ] \stemUp g8 [ \stemUp a8 ] r4
    | % 56
    \stemUp f8 r8 \stemUp g8 [ \stemUp a8 ] r4 \stemUp f4 ~ | % 57
    \stemUp f4 r2 r4 | % 58
    r8 \stemUp e8 r8 \stemUp g8 [ \stemUp e8 \stemUp f8 \stemUp g8 ] s8
    | % 59
    r8 \stemUp e8 r8 \stemUp e2 r8 |
    r8 \stemUp f8 [ \stemUp g8 \stemUp a8 ] r8 r4 r8 | % 61
    \stemUp a4. \stemUp g4. r4 | % 62
    \stemUp g4. \stemUp f4. r4 | % 63
    r8 \stemUp a8 [ \stemUp g8 \stemUp f8 \stemUp g8 \stemUp a8 ] r4 | % 64
    \stemUp a8 r8 \stemUp a8 [ \stemUp a8 ] r4 \stemUp a4 ~ |  \break % 65
              \inst "H"
    \stemUp a4 ^ "Coro y Pregón" r4 r2 | % 66
    r2 r8 \stemUp e8 [ \stemUp f8 \stemUp g8 ] | % 67
    r8 \stemUp e4 r8 r2 | % 68
    r2 r8 \stemUp a8 r8 \stemUp a8 ~ | % 69
    \stemUp a2. r4 | 
    R1 | % 71
    R1 | % 72
    R1 | % 73
    R1 | % 74
    r2 r8 \stemUp e8 [ \stemUp f8 \stemUp g8 ] | % 75
    r8 \stemUp e4 r8 r2 | % 76
    r2 r8 \stemUp d8 [ \stemUp e8 \stemUp f8 ~ ] | % 77
    \stemUp f4 r4 r2 | % 78
    R1 | % 79
    R1 | 
    R1 | % 81
    R1 | % 82
    r2 r4 r8 \stemUp e8 | % 83
    r8 \stemUp g8 r4 r2 | % 84
    r2 r8 \stemUp e8 r8 \stemUp d8 ~ | % 85
    \stemUp d2. r4 | % 86
    R1 | % 87
    R1 | % 88
    R1 | % 89
    R1 | 
    r4 r8 \stemUp f8 [ \stemUp e8 \stemUp d8 ] \stemUp e4 | % 91
    r8 \stemUp cis8 [ \stemUp c8 \stemUp cis8 \stemUp e8 \stemUp cis8
    \stemUp e8 \stemUp d8 ] | % 92
    r8 \stemUp f4 r4 \stemUp f8 [ \stemUp g8 \stemUp a8 ] | % 93
    \stemUp a4. \stemUp g4. r4 | % 94
    \stemUp g4. \stemUp f4. r4 | % 95
    R1 | % 96
    \stemUp f8 r8 \stemUp f8 [ \stemUp f8 ] r2 | % 97
 
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

\score {
  \unfoldRepeats {
    \transpose a c \Sax
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