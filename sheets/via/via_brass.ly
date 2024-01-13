\version "2.24.0"

% Sheet revision 2022_09

% for score rendering
% - comment \repeatBracket command
% - comment markups that denote percussion repeats, e.g. ^\markup { \bold { \fontsize #2 "8x" } }
% - use simple page counter, only: \fromproperty #'page:page-number-string

\header {
  title = "24. Via"
  instrument = "brass"
  composer = "Al De Lory"
  arranger = "arr. Pavel Skalník + Ladislav Maršík"
  opus = "version 1.12.2023"
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
\relative c'' {
  \set Staff.instrumentName = \markup {
    \center-align { "Tr. in C" }
  }
  \set Staff.midiInstrument = "trumpet"
  \set Staff.midiMaximumVolume = #1.0

  \key g \minor
  \time 4/4
  \tempo "Medium Fast Instrumental Salsa" 4 = 180

  s1*0
  ^\markup { "Piano intro" }
  \inst "in"
  R1*8

  \repeat volta 2 {
    R1 ^\markup { "con bajo" } |
    r2 r4. g8 \fp \< ~ |
    g1 ~ |
    g1 \f
  }

  s1*0
  ^\markup { "Verso 1" }
  \inst "A1"
  R1*16 \break

  s1*0
  ^\markup { "Ritmo 1" }
  \inst "B1"
  es4 -. \mf r2 r8 f8 -. ~ |
  f8 r8 r2 r8 g8 -. ~ |
  g8 r8 r2 r8 a8 -. |
  r8 g8 -. r8 f8 -. r8 es4 -- r8|
  d4 -. r2 r8 es8 -. ~ |
  es8 r8 r2 r8 f8 -. ~ |
  f8 r8 r2 r8 g8 -. |
  r8 f8 -. r8 es8 -. r8 d4 -- r8 |
  c4 -. r2 r8 d8 -. ~ |
  d8 r8 r2 r8 es8 -. ~ |
  es8 r8 r2 r8 f8 -. |
  r8 es8 -. r8 d8 -. r8 c4 -- r8 | \break
  
  s1*0
  ^\markup { "Bridge 1" }
  \inst "C1"
  \repeat volta 2 {
    R1 |
    r2 r4. g'8 \mf \< ~ |
    g1 ~ |
    g1 \f |
  }

  s1*0
  ^\markup { "Verso 2" }
  \inst "A2"
  R1*16 

  s1*0
  ^\markup { "Ritmo 2" }
  \inst "B2"
  es4 -. \mf r2 r8 f8 -. ~ |
  f8 r8 r2 r8 g8 -. ~ |
  g8 r2. a8 -. |
  r8 g8 -. r8 f8 -. r8 es4 -- r8|
  d4 -. r2 r8 es8 -. ~ |
  es8 r8 r2 r8 f8 -. ~ |
  f8 r8 r2 r8 g8 -. |
  r8 f8 -. r8 es8 -. r8 d4 -- r8 |
  c4 -. r2 r8 d8 -. ~ |
  d8 r8 r2 r8 es8 -. ~ |
  es8 r8 r2. |
  R1 ^\markup { "Buildup 1" } |
  r2 r4. f8 \mf ~ |
  f1 |
  
  s1*0 
  ^\markup { "Chorus 1" }
  \inst "D1"
  R1*24 \break

  s1*0 
  ^\markup { "Bridge 2" }
  \inst "C2"
  \repeat volta 2 {
    R1|
    r2 r4. g8 \mf \< ~ |
    g1 ~ |
    g1 \f
  }
  
  s1*0 
  ^\markup { "Modulation" }
  \key a \minor
  \inst "E"
  \repeat volta 2 {
    R1|
    r2 r4. a8 \mf \< ~ |
    a1 ~ |
    a1 \f
  } \break

  s1*0 
  ^\markup { "Verso 3 (stop - piano solo)" }
  \inst "A3"
  R1*7
  r8 a8 -. \mp a8 -. r8 g8 -. a8 -. r4 |
  R1*7
  a8 -. \mp r8 g8 -. a8 -. r8 g8 -. r4 | \break

  s1*0
  ^\markup { "Ritmo 3" }
  \inst "B3"
  f4 \mf -. r2 r8 g8 -. ~ |
  g8 r8 r2 r8 a8 -. ~ |
  a8 r8 r2 r8 b8 -. |
  r8 a8 -. r8 g8 -. r8 f4 -- r8 |
  e4 -. r2 r8 f8 -. ~ |
  f8 -. r2. g8 -. ~ |
  g8 r8 r2 r8 a8 -. |
  r8 g8 -. r8 f8 -. r8 e4 -- r8 |
  d4 -. r2 r8 e8 -. ~ |
  e8 r2. f8 -. ~ |
  f8 r4. r2 |
  R1 | \break

  s1*0 
  ^\markup { "Verso 4 (attacca)" }
  \inst "A4"
  R1*5
  d'1 \mp \< | 
  a4 \mf -- b4 -- c4 -- e,8 -. b'8 -- ~ |
  b8 a8 -- ~ a8 r8 r2 |
  R1*7|
  r8 g8 -. \mp r8 f8 -. g4 -- r4 | \break
  
   s1*0
  ^\markup { "Ritmo 4" }
  \inst "B4"
  f4 \mf -. r2 r8 g8 -. ~ |
  g8 r8 r2 r8 a8 -. ~ |
  a8 r8 r2 r8 b8 -. |
  r8 a8 -. r8 g8 -. r8 f4 -. r8 |
  e4 -. r2 r8 f8 -. ~ |
  f8 -. r2. g8 -. ~ |
  g8 r8 r2 r8 a8 -. |
  r8 g8 -. r8 f8 -. r8 e4 -. r8 |
  d4 -. r2 r8 e8 -. ~ |
  e8 -. r2. f8 -. ~ |
  f8 -. r4. r2| \break
  
  R1 ^\markup { "Buildup 2" } |
  r2 r4.  g8 \mf ~ |
  g1 |
  
  s1*0 
  ^\markup { "Chorus 2" }
  \inst "D2"
  R1*12 |
  R1 * 5
  r2 r8 d8 -. \mf r8 e8 -. |
  R1*6 \break

  s1*0 
  ^\markup { "Coda" }
  \inst "E"
  \repeat volta 4 {
    R1 |
    \alternative {
      {
        r2 r4. a8 \mf \< ~ |
    a1 ~ |
    a1 \f
      }
      {
        r2 r4. a8 \mf \< ~ |
        a1 |
        r8 c8 -- \f r8 c8 -- r8 b8 -- r4 |
      }
    }
  }

  \label #'lastPage
  \bar "|."
}

Sax = \new Voice
\transpose c a'
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "A. Sax in C" }
  }
  \set Staff.midiInstrument = "Trombone"
  \set Staff.midiMaximumVolume = #1.0

  \key g \minor
  \time 4/4
  \tempo "Medium Fast Instrumental Salsa" 4 = 180

  s1*0
  ^\markup { "Piano intro" }
  \inst "in"
  R1*8
  
  \repeat volta 2 { r2 ^\markup { "con bajo" } r4.g8 \fp \< ~|g2.~g8g8~|g1~|g1 \mf }
  s1*0
  ^\markup { "Verso 1" }
  \inst "A1"
  R1*16 \break
  
    s1*0
  ^\markup { "Ritmo 1" }
  \inst "B1"
  g4  -. \mf r2r8a8 -. ~| a8 r8r2r8bes8 -. ~| bes8 r2.c8 -. | r8bes8 -. r8a8 -. r8g4 -- r8|
  f4 -. r2r8g8 -. ~| g8 r2.a8 -. ~| a8 r2.bes8 -. | r8a8 -. r8g8 -. r8f4 -- r8|
  es4 -. r2r8f8 -. ~| f8 r2.g8 -. ~| g8 r2.a8 -. | r8g8 -. r8f8 -. r8es4 -- r8| \break 

   s1*0
  ^\markup { "Bridge 1" }
  \inst "C1"
  \repeat volta 2 { r2 r4.g8 \mp \< ~|g2.~g8g8~|g1~|g1 \f }

  s1*0
  ^\markup { "Verso 2" }
  \inst "A2"
  R1*16 
  
    s1*0
  ^\markup { "Ritmo 2" }
  \inst "B2"
  g4 \mf -. r2r8a8 -. ~| a8 r8r2r8bes8 -. ~| bes8 r2.c8 -. | r8bes8 -. r8a8 -. r8g4 -. r8|
  f4 -. r2r8g8 -. ~| g8 r2.a8 -. ~| a8 r2.bes8 -. | r8a8 -. r8g8 -. r8f4 -. r8|
  es4 -. r2r8f8 -. ~| f8 r2.g8 -. ~| g8 r4. r2 | r2  ^\markup { "Buildup 1" } r4. f8 \mp ~|f1~|f1
  s1*0 
  ^\markup { "Chorus 1" }
  \inst "D1"
  R1*24 \break
  s1*0 
  ^\markup { "Bridge 2" }
  \inst "C2"
  \repeat volta 2 { r2 r4.g8 \mp \< ~|g1~|g1~|g1 \f }
  s1*0 
  ^\markup { "Modulation" }
  \key a \minor
  \inst "E"
  \repeat volta 2 { r2 r4.a8~\mp \< |a1~|a1~|a1 \f }
  
    s1*0 
  ^\markup { "Verso 3 (stop - piano solo)" }
  \inst "A3"
  R1*7
  r8e8 -. \mp e8 -. r8d8 -. e8 -. r4| R1*7| e8 \mp -. r8d8 -. e8 -. r8d8 -. r4| \break
  
    s1*0
  ^\markup { "Ritmo 3" }
  \inst "B3"
  a4 \mf -. r2r8b8 -. ~| b8r8r2r8c8 -. ~| c8 r2.d8 -. | r8c8 -. r8b8 -. r8a4 -- r8|
  g4 -. r2r8a8 -. ~| a8r2.b8 -. ~| b8 r2.c8 -. | r8b8 -. r8a8 -. r8g4 -- r8|
  f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r4. r2 |
  R1 | \break
  s1*0 
  ^\markup { "Verso 4 (attacca)" }
  \inst "A4"
  R1*5
  d'1  \mp \< |a4 \mf -- b4 -- c4 -- e,8 -. b'8 --~  |b8 a8-- ~ a8 r8 r2|
  R1*7|
  r8e8 \mp -. r8d8 -. e4 -- r4 | \break
  
     s1*0
  ^\markup { "Ritmo 4" }
  \inst "B4"
  a, 4 \mf -. r2r8b8 -. ~| b8r8r2r8c8 -. ~| c8 r2.d8 -. | r8c8 -. r8b8 -. r8a4 -- r8|
  g4 -. r2r8a8 -. ~| a8r2.b8 -. ~| b8 r2.c8 -. | r8b8 -. r8a8 -. r8g4 -- r8|
  f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r8 r4 r2| \break
  
  r2 ^\markup { "Buildup 2" }  r4.g8 \mp ~ |g1 ~|g1|
  s1*0 
  ^\markup { "Chorus 2" }
  \inst "D2"
  R1*12
  R1 * 5
  r2r8b8\mf -. r8c8 -.  |
  R1*6| \break
  
  s1*0 
  ^\markup { "Coda" }
  \inst "E"

  \repeat volta 4 {
    
    r2 r4.a8~ \mp \< |
    
    \alternative {
      {
    a1~|a1~|a1 \f
      } 
      {
        a2. ~a8a8~|a1 |r8c8 \f -- r8c8 -- r8b8 --r4|
      }
    }
  }

  \label #'lastPage
  \bar "|."
}

Trombone = \new Voice
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Bone in C" }
  }
  \set Staff.midiInstrument = "Trombone"
  \set Staff.midiMaximumVolume = #1.0

\clef bass
  \key g \minor
  \time 4/4
  \tempo "Medium Fast Instrumental Salsa" 4 = 180

  s1*0
  ^\markup { "Piano intro" }
  \inst "in"
  R1*8

\repeat volta 2 { r2 ^\markup { "con bajo" }  r4.g8 \fp \<~|g2.~g8g8~|g1~|g1 \mf }
  s1*0
  ^\markup { "Verso 1" }
  \inst "A1"
  R1*16 \break
  
      s1*0
  ^\markup { "Ritmo 1" }
  \inst "B1"
g4 \mf -. r2r8a8 -. ~| a8r8r2r8bes8 -. ~| bes8 r2.c8 -. | r8bes8 -. r8a8 -. r8g4 -- r8|
f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r2.bes8 -. | r8a8 -. r8g8 -. r8f4 -- r8|
es4 -. r2r8f8 -. ~| f8r2.g8 -. ~| g8 r2.a8 -. | r8g8 -. r8f8 -. r8es4 -- r8| \break

   s1*0
  ^\markup { "Bridge 1" }
  \inst "C1"
\repeat volta 2 { r2 r4.g8  \mp \<  ~|g1~|g1~|g1 \mf }
  s1*0
  ^\markup { "Verso 2" }
  \inst "A2"
  R1*16 
  
      s1*0
  ^\markup { "Ritmo 2" }
  \inst "B2"
g4 \mf -. r2r8a8 -. ~| a8r8r2r8bes8 -. ~| bes8 r2.c8 -. | r8bes8 -. r8a8 -. r8g4 -- r8|
f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r2.bes8 -. | r8a8 -. r8g8 -. r8f4 -- r8|
es4 -. r2r8f8 -. ~| f8r2.g8 -. ~| g8 r8r4r2|r2 ^\markup { "Buildup 1" }  r4.f8 \mp ~|f1~|f 1
 s1*0 
  ^\markup { "Chorus 1" }
  \inst "D1"
  R1*24 \break 
  s1*0 
  ^\markup { "Bridge 2" }
  \inst "C2"
\repeat volta 2 { r2 r4.g8 \mp \< ~|g1~|g1~|g1 \f }
  s1*0 
  ^\markup { "Modulation" }
  \key a \minor
  \inst "E"
\repeat volta 2 { r2 r4.a8 \mp \< ~|a1~|a1~|a1 \f }

  
    s1*0 
  ^\markup { "Verso 3 (stop - piano solo)" }
  \inst "A3"
  R1*7
r8c8 \mp -. c8 -. r8b8 -. c8 -. r4| R1*7| c8 \mp -. r8b8 -. c8 -. r8b8 -. r4| \break

  s1*0
  ^\markup { "Ritmo 3" }
  \inst "B3"
a4 \mf r2r8b8 -. ~| b8r8r2r8c8 -. ~| c8 r2.d8 -. | r8c8 -. r8b8 -. r8a4 -- r8|
g4 -. r2r8a8 -. ~| a8r2.b8 -. ~| b8 r2.c8 -. | r8b8 -. r8a8 -. r8g4 -- r8|
f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r4. r2 |
  R1 | \break
  s1*0 
  ^\markup { "Verso 4 (attacca)" }
  \inst "A4"
R1*5
d'1 \mp \< |a4 \f -- b4 -- c4 -- e,8 -. b'8 -- ~| b8 a8 -- ~ a8 r8 r2|
R1*7|
r8c8 \mp -. r8b8 -. c8 -. r8r4 | \break

     s1*0
  ^\markup { "Ritmo 4" }
  \inst "B4"
a,4 \mf -. r2r8b8 -. ~| b8r8r2r8c8 -. ~| c8 r2.d8 -. | r8c8 -. r8b8 -. r8a4 -- r8|
g4 -. r2r8a8 -. ~| a8r2.b8 -. ~| b8 r2.c8 -. | r8b8 -. r8a8 -. r8g4 -- r8|
f4 -. r2r8g8 -. ~| g8r2.a8 -. ~| a8 r8 r4 r2|r2 ^\markup { "Buildup 2" } r4.g8 \mp ~ |g1~|g1 |
s1*0 
  ^\markup { "Chorus 2" }
  \inst "D2"
  R1*12
  R1 * 5
r2r8b8 \mf -. r8c8 -. |R1*6| \break
  s1*0 
  ^\markup { "Coda" }
  \inst "E"
\repeat volta 4 {
  r2 r4.a8 \mp \< ~|
                  \alternative { 
                   {
                     a1~|
                  a1~|
                  a1 \f 
                   }
                   {
                     a1 ~|a1|r8c8 \f -- r8c8 -- r8b8 -- r4|
                   }
                  }
}

  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \unfoldRepeats {
    \new StaffGroup \with {
      \consists "Volta_engraver"
    }<<
      \new Staff << \transpose d c \Trumpet >>
      \new Staff << \transpose a c \Sax >>
      \new Staff << \Trombone >>
    >>
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
    <<
      \transpose d c  \Trumpet 
      \transpose a c \Sax 
      \Trombone
    >>
  }
  \midi { } 
}

\paper {
  system-system-spacing =
  #'((basic-distance . 15)
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
      %\concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
      \fromproperty #'page:page-number-string 

      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }
    }
  }
  evenFooterMarkup = \markup {
    \fill-line {
      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }

      \bold \fontsize #2
      %\concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
      \fromproperty #'page:page-number-string
    }
  }
}