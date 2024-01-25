\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "Sera Que No Me Amas"
  instrument = "sax"
  composer = "by Tony Succar feat. Michael Stuart"
  arranger = "arr. Ladislav Maršík"
  opus = "version 22.1.2024"
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
\transpose c a
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9
  \override Staff.BreathingSign.text = \markup { \musicglyph "scripts.rvarcomma" }
  \set breathMarkType = #'tickmark

  \key c \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190  
    
  s1*0 ^\markup { "Intro" }
  \inst "A"
  c4 -- \mf  c -. e, -- e -. |
  r8 a -. r e -. r e d -. r |
  r4. d8 -- d -. r r e -. |
  r f -. r fis -. r g a g | \break
  c4 -- c -. e, -- e -. |
  r8 a -. r e -. r e d -. r |
  r4. d8 -- d -. r r e -. |
  r f -. r fis -. r g a g | \break
  c4 -- c -. e, -- e -. |
  r8 a -. r e -. r e d -. r |
  r4. d8 -- d -. r r e -. |
  r f -. r fis -. r g a g | \break
  c4  -- c -. e, -- e -. |
  r8 a -. r e -. r e d -. r |
  r4. d8 -- d -. r r e -. |
  r f -. r fis -. r as4. -- | \break

  \mark \markup { \musicglyph "scripts.segno" }
  s1*0 ^\markup { "Verse 1 & 2" }
  \inst "B1,2"
  
  \repeat volta 2 { 
  c4 \accent  \bendAfter #-4  r4 r8 e -. r a -.  |
  r8 g -. r d -. r e -- c4 -. | 
  r4. bes8 -- bes4 -. r4  |
  r8 c8 \accent r4 g2 --  |
  a8 -- a -. r4 g8 -- a -. r4 |
  r4. d,8 -- ~ d2  |
  f4 \tenuto ( as -. ) r4 c \f \accent ~ |
  c8 e -. r g -. r e -- d4 -. | \break
  R1 |
  r8 a' \mf ( g e g a -. ) r4  |
  R1*2 ^\markup { "Trombone" }
  r4. f,8 -^ \f r2 |
  r4. c'8 \accent ~ c4 \bendAfter #-4 r4 |
  r4. g'8 ( g e g c -^ ) |
  r8  b -^ r2. | \break
  
  s1*0 ^\markup { "Chorus 1 & 2" }
  \inst "C1,2"
  r2 r8 g, -- a -. r | 
  c -^ c -^ r2. |
  r2 r8 f -. \mf r bes -. | 
  r g4. -- f8 bes, bes4 -.  |
  r2.bes4 -^ \f |
  r8 bes8 -^ r2. |
  r4. g8 -. \mf r a -- ~ a g |
  c4 -. r8 c c4 -. r | \break
  r2 r8 g \f a4 -. | 
  r8 c \accent ~ c4 \bendAfter #-4 r2 |
  r2 r8 f -. \mf r \breathe bes -. | 
  r g4. -- f8 bes, bes4 -. | \break
    r2.bes4 -^ \f |
  r8 bes8 -^ r2. |
   \alternative {
     {
        r8 g'8 \mf  \tenuto d \tenuto es \tenuto  e \tenuto g \tenuto e \tenuto a -^  |
        R1 |
     }
     {
       r4. g,8 -. \mf   r c -. r a' -. | 
       r g4.\turn e8 d e4 -. | \break
     }
   }
  }
 
 s1*0 ^\markup { "Ya No Se" }
 \inst "D"
 R1*8 

  r2 r8 c'4. \accent \f |
  r2 r8 c,4.  \mf \accent |
  r4. a'8 \f -. r a -- g -. g -. -. |
  R1  | \break
  
  r2 r8 c4. \accent |
  r2 r4. g,8 \mf \< |
  c4. d8 ~ d4.es8 ~ |
  es4.  f8 \f  g f g4 -^ | \break
  
   s1*0 ^\markup { "Chorus" } 
   \inst "C3"
  a8  -. \accent  r4. r8 g, -- a -. r \breathe | 
  c -^ c -^ r2. |
  r2 r8 f -. \mf r \breathe bes -. | 
  r g4. -- f8 bes, bes4 -. |
    r2.bes4 -^ \f |
  r8 bes8 -^ r2. |
  r4. g8 \mf r a4 -- g8 |
  c4 -. r8 c c4 -. r |
  r2 r8 g \f a4 -. | 
  r8 c \accent ~ c4 \bendAfter #-4 r2 |
  r4. c8 \mf g' g fis g | 
  es f g4 -^ r2 |
  as,4. -> g8 -^ r f' d bes |
  r g -> \f r es' -> r es ( d c |
  d c ~ c2 ) r8 bes -> |
  R1 |
  
  
  
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