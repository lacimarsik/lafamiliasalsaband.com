\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "Sera Que No Me Amas"
  instrument = "bass"
  composer = "by Tony Succar feat. Michael Stuart"
  arranger = "arr. Ladislav Maršík"
  opus = "version 15.2.2023"
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

Bass = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Bass" }
  }
  \set Staff.midiInstrument = "acoustic bass"
  \set Staff.midiMaximumVolume = #1.5

  \clef bass
  \key a \minor
  \time 4/4
  \tempo "Allegro" 4 = 180

  s1*0 ^\markup { "Intro" }
  \inst "A"
  c4 c e e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis r g a g | \break
  c4  c e, e |
  r8 a r e r e d r |
  r4. d8 d r r e |
  r f r fis g2 | \break
  \mark \markup { \musicglyph "scripts.segno" }

  s1*0 ^\markup { "Verse 1 & 3" }
  \inst "B = I"
  a,4 r r8 e' r a |
  r g r d r e c r |
  r4. bes8 ~ bes2 |
  r8 c r4 g2 | \break
  a4 r g8 a r4 |
  r d,4 ~ d r |
  f4 g ~ g c ~ |
  c1 |

  s1*0 ^\markup { "Salsa" }
  \repeat percent 8 { \makePercent s1 }
  \break

  s1*0 ^\markup { "Chorus 1 & 3" }
  \inst "C = J"
  \repeat percent 8 { \makePercent s1 }
  \break
  \makePercent s1 |
  r8 f,8 ~ f2. |
  \repeat percent 6 { \makePercent s1 }
  \break
  
  s1*0 ^\markup { "Verse 2 & 4" }
  \inst "D = K"
  a4 r r8 e' r a |
  r g r d r e c r |
  r4. bes8 ~ bes2 |
  r8 c r4 g2 | \break
  a4 r g8 a r4 |
  r d,4 ~ d r |
  f4 g ~ g c ~ |
  c1 |
  
  s1*0 ^\markup { "Salsa" }
  \repeat percent 8 { \makePercent s1 }
  \break
  
  s1*0 ^\markup { "Chorus 2 & 4" }
  \inst "E = L"
  \repeat percent 8 { \makePercent s1 }
  \break
  \makePercent s1 |
  r8 f,8 ~ f2. |
  \repeat percent 6 { \makePercent s1 }
  \break
  
  s1*0 ^\markup { "Ya No Se (calm)" }
  \inst "F = M"
  \repeat percent 8 { \makePercent s1 }
  \break
  
  s1*0 ^\markup { "Salsa" } 
  \repeat percent 6 { \makePercent s1 }
  d4. a'8 ~ a4. bes8 ~ |
  bes4. g8 ~ g2 | \break
  \mark \markup { \musicglyph "scripts.coda" } 
  
  s1*0 ^\markup { "Chorus" } 
  \inst "G"
  R1*8
  R1 |
  r8 f8 ~ f2. |
  R1*6 \break

  \inst "H" 
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trombone (C, E, F, G)" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Sax" }
  \set Score.skipBars = ##t R1*16 ^\markup { "Solo Piano" } |
  r1 \fermata ^\markup { "Wait for apel" } | |
  g8 \f g -. r g -. r g ~ g4 \tenuto  ^\markup { "D.S. al Coda" } | \break

  s1*0 ^\markup { "Coda 1 4x" } 
  \repeat volta 4 {
  R1*4 | \break
  }

  s1*0 ^\markup { "Coda 2 3x" } 
  \inst "N"
  \repeat volta 4 {
    c8 c r a r c r d \fermata ^\markup { "wait on D on 3rd" } |
    r es r e r g a g |   \break 
  }

  c,8 c r a r c r d |
  r es r e r g a g |   
  c,8 \accent r8 r2. |
  
  \label #'lastPage
  \bar "|."  
}

Chords = \chords {
  R1*24

  a1:m  | a:m |  c  |  c  |
  f  | f | g | g  | \break
  c | c | es | es |
  bes | bes | c | c |
  c | r  | es | es |
  bes | bes | c | c |
  
  R1*8
  
  a1:m  | a:m |  c  |  c  |
  f  | f | g | g  | \break
  c | c | es | es |
  bes | bes | c | c |
  c | r  | es | es |
  bes | bes | c | c |
  
  c  | e:m |  f  |  g  |
  c  | e:m |  f  |  g  | \break
  
  c  | a:m |  f  |  g  |
  c  | a:m | r  | r  \break
  c | c | es | es |
  bes | bes | c | c |
  c | r  | es | es |
  bes | bes | c | c |
  R1*66
  
  c1  | e:dim |  f  |  g  |  \break
  
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Bass
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