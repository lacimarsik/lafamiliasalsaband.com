\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "#18 I Want You Back"
  instrument = "sax"
  composer = "by Tony Succar feat. Tito Nieves"
  arranger = "arr. Ladislav Maršík, Pavel Skalník"
  opus = "version 23.4.2023"
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
\relative c, {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Eb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #1.0

  \key es \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190
  
  R1 ^\markup { "Piano Slide" }
  
  \inst "A"
  es4 -> -. \f ^\markup { "Guitar + Sax Intro" }  r4 r2 | 
  r4 r8 es8 \mf -- g8 -- bes8 -- c8 -- as8 -. |
  R1 |
  r8 f8 -- g8 -- as8 -- r8 a8 -- bes8 -- ces8 -- | 
  c2 --  g2 -- | 
  as4. --  es4. -- r4 | 
  f2 --  bes4. --  es,8 -. |
  R1 | \break
  
  es4 -> -. \f ^\markup { "Brass Intro" } r4 r2 |
  r4 r8 es8 \mf -- g8 --  bes8 -- c8 -- as8 --  | 
  R1 |
  r8  f8 -- g8 -- as8 -- r8  a8 -- bes8 -- ces8 -- | 
  c2 -- g2 -- | 
  as4. --  es4. -- r4 | 
  f2 --  bes4. --  es,8 -. | 
  R1  |  \break
  
    \inst "A"
  es'8 -- \f ^\markup { "Brass 1" } es8 -.  r8  es8 ( d8   es8  c8  bes8 ~  | 
  bes4 ) es4 -. es4 -. r4 | 
  r8 c8 \mf es8 -- c8 -- es8 -- es8 -- c8 -- es8 -- ~  | 
  es8 es8 -- fes8 -- f8 -- es4 -. r4 |
  r2 es8 -- f8 -- g8 -- as8 -- ~ | 
  as4 g4 -- f4 -- es4 -- | 
  f2 --  bes4. -> -- es,8 -. | 
  r8 es,8 -. es8 -. es8 -. es4 -. bes'8 ( c8 | 
  \break

  es4 ) -> ^\markup { "Verse" } \segno r4 r2 |
  r4 r8 es,8 \mf -- g8 -- bes8 -- c8 -- as8 -. |
  R1 |
  r8 f8 -- g8 -- as8 -- r8 a8 -- bes8 -- ces8 -- | 
  c2 --  g2 -- | 
  as4. --  es4. -- r4 | 
  f2 --  bes4. --  es,8 -. |
  R1 | \break
  
   es4 -> -. \f r4 r2 |
  r4 r8 es8 \mf -- g8 --  bes8 -- c8 -- as8 --  | 
  R1 |
  r8  f8 -- g8 -- as8 -- r8  a8 -- bes8 -- ces8 -- | 
  c2 -- g2 -- | 
  as4. --  es4. -- r4 | 
  f2 --  bes4. --  es,8 -. | 
  R1  |  \break
  
  \inst "B"
  es'4 -> \f \bendAfter #-4 ^\markup { "Chorus" }   r4  f8 -- g8 -- f8 -- g8 -- ~ |  
  g4  es4 -.  es4 -. r4 | 
  r8 c8 -- es8 -- f8 -- \tuplet 3/2 { g8 ( as8 g8 } f8 bes8 -> ~ | 
  bes2 ) r2 | 
  r4  c,4 -. r4 c4 -. | 
  r8  c8 -. r8  c8 -- bes8 -- c8 -- es4 -. | 
  r4  f,4 -.  bes4. --  es,8 -. | 
  R1  | 
  r2  bes''4 \f -> \bendAfter #-4 r4 | 
  r4 r8  bes8 \mf -. r8  bes8 -. r8  bes8 -. |
  as4 --  as4 -. r2 | 
  r8 g8 --  f4 -.  g8 -- 
  bes8 -.  r4  | 
  r4  c,4 -. r4  c4 -. | 
  r8  c8 -. r8 c8 -- bes8 -- c8 --  es4 -. |
  r4  f,4 -.  bes4. --  es,8 -. ^\markup { "to " \musicglyph "scripts.coda" } |
  r8  es8 -.   es8 -.  es8 -.   es4 -. r4 |
  \break

  \inst "C" 
  R1 ^\markup { "I want you back" } |
  r8 es'8 -.   es8 -.  es8 -.  es4 -. r4 | 
  es4 -.  bes4 -. r8 es4. -. |
  r8  es8 -.   es8 -.  es8 -. 
  es4 -. r4  | 
  R1 | 
  r8  es8 -.   es8 -.  es8 -. 
  es4 -. r4 | 
  es4 -.  bes4 -. r8  es,4. -. | 
  r8  es8 -.   es8 -.  es8 -.   ^\markup { "Dal " \musicglyph "scripts.segno" " al " \musicglyph "scripts.coda" }  es4 -. r4  | 
  \break
  
  \mark \markup { \musicglyph "scripts.coda" }
  R1 | 
    \inst "D"
  es'8 -- \f ^\markup { "Brass 2" }  es8 -.  r8  es8 ( d8 es8  c8  bes8 ~  | 
  bes4 ) es4 -.  es4 -. r4 |  \noBreak
  r8  c8 --  es8 --  c8 -- es8 -- es8 -- c8 -- es8 ~  | 
  es8  -- es8 -- fes8 --  f8 -- es4 -. r4  | 
  r8 es8 -- f8 -- g8  -- \tuplet 3/2 { as8  ( bes8  as8 } g8  ges8 ) | 
  f4 -.  f4 -.  g8 -- f8 -- es4 -. |
  R1 | 
  r2 r8  es,8 -> \bendAfter #-4 r4 |
  \break 
  
    \inst "E"   
  \set Score.skipBars = ##t R1*2  ^\markup { "Coro y Pregón 1" }
  r4 r8 c'8 -- \mp ^\markup { "(laid back)" } \tuplet 3/2 { es4 -- fes4 -- f4 -- } ~  | 
  f2.. \prallprall r8  |
  \set Score.skipBars = ##t R1*3
 r2 r4 bes,8 \mf -> c8 ->  es4 -^ bes8 -> c8 -> es4 -^ r4 | 
  r2 r4 c8 -> es8 ->  | 
  f4 -^ c8 -> es8 -> f4 -^ r4 |
        \set Score.skipBars = ##t R1*5
    \break
 \repeat volta 2 {
    \set Score.skipBars = ##t R1*2
 r4 r8 c8 -- \mp ^\markup { "(laid back)" } \tuplet 3/2 { es4 -- fes4 -- f4 -- } ~  | 
  f2.. \prallprall r8  |
    \set Score.skipBars = ##t R1*4
 }
    \break
    
      \inst "F"     
\repeat volta 2 {
    r8 ^\markup { "Sax Mambo" } es,8 \f -. r8 g8 -. bes8 -. c8 -.  r8 bes8 -. | 
    r8 f8 -- c'8 -- d8 -- f8 -- f8 -- d4 -. | 
    r8 bes -. r8 d8 -. c8 -. bes8 -. r8 es,8 -. | 
    r8 bes'8 -- r8 bes8 -- c8 -- bes8 -- c4 -.  | 
}
      \break
      
        \inst "G" 
              \set Score.currentBarNumber = #115
      \repeat volta 2 {
    r8 ^\markup { "Brass 3" } es,8 \f  -. r8 g8 -. bes8 -. c8 -.  r8 bes8 -. | 
    r8 f8 -- c'8 -- d8 -- f8 -- f8 -- d4 -. | 
    r8 bes -. r8 d8 -. c8 -. bes8 -. r8 es,8 -. | 
    r8 bes'8 -- r8 bes8 -- c8 -- bes8 -- c4 -.  | 
     r8 es,8 -. r8 g8 -. bes8 -. c8 -.  r8 bes8 -. | 
    r8 f8 -- c'8 -- d8 -- f8 -- f8 -- d4 -. | 
    r8 bes -. r8 d8 -. c8 -. bes8 -. r8 es,8 -. | 
    r8 bes'8 -- r8 bes8 -- c8 -- bes8 -- c4 -.  | 
      }

      \break
      
    \inst "H"    
      \set Score.currentBarNumber = #125
  \set Score.skipBars = ##t R1*32  ^\markup { "Coro y Pregón 2" }
  \break
  
  \inst "I"     
  \repeat volta 2 {
  g8 \mf --  ^\markup { "Petas" } bes8 -.  r8 c8 -. d4 -- \bendAfter #-4 r4 |  \noBreak
  r8  bes8 --  bes8 -- d8 -- r8  d8 -- r8  bes8 -- | \noBreak
  r8  d8 -- r8  bes8 -- d4 \bendAfter #-4 r8 g,8 -. | \noBreak 
  r8  bes4. -- r8  g8 --  g8 -- g8 --  | \break
  g8 -- bes8 -. r8 c8 -. d4 -- \bendAfter #-4 r4 |  \noBreak
r8  bes8 --  bes8 -- d8 -- r8  d8 -- r8  bes8 -- | \noBreak
  r8  d8 -- r8  bes8 -- d4 \bendAfter #-4 r8 g,8 -. | \noBreak
  }
  \alternative {
    {
  r8  bes4 -.  es8 ~  es4 r4 | 
  }
  {
      r8  bes4 -.  g8 ~  g2  |
  }
  }
  \break
  
  \inst "J"
  \set Score.skipBars = ##t R1*23  ^\markup { "Coro y Pregón 3" }
  \break
  
  
  r4. bes8 \f -- c8 -- d8 -- es8 -- f8 -- | \noBreak
      \inst "K"
      
  g8 ^\markup { "Coda" } --  g8 -- f8 --  g8 --  r8 as8 -. r8  a8 -. |  \noBreak
  r8  f8 --  es4 -.  es4 -- f4 -. | \noBreak
    r8 as,8 \bendAfter #-4 -- r8 g8 \bendAfter #-4 -- r8 f8 -- r8 es8 ~ -- | 
  es2 r2  | 
  r8  g'8 -. r8  g8 -.  c,8 --  c8 -.  r8  f8 -- ~ | 
  f4 r8 as8 -- r8 as8 -- g8 -- ges8 -- | 
  f2 ->  bes,4. ->  es,8 -^ \ff
  
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
    \Sax
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



