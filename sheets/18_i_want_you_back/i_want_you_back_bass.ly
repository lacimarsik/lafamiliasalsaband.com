\version "2.24.0"

% Sheet revision 2022_09

\header {
  title = "#18 I Want You Back"
  instrument = "bass"
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

Bass = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "Bass" }
  }
  \set Staff.midiInstrument = "acoustic bass"
  \set Staff.midiMaximumVolume = #1.5

  \clef bass
  \key es \major
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190
  
  R1 ^\markup { "Piano Slide" }
  
  \inst "A"
  es,4 -> -. \f r4 r2  |
    R1*7 ^\markup { "Guitar + Sax Intro" }
  es4 -> -. ^\markup { "Brass Intro" } r2. |
  r4. es8 -- \mf g8 -- bes8 -- c8 -- as8 -- |
  R1 |
  r8 f8 -- g8 -- as8 -- r8 a8 -- bes8 -- ces8 -- | 
  c2 -- g2 -- | 
  as4. -- es4. -- r4 | 
  f2 -- bes4. -- es,8 -. | 
  R1 | \break
  
  \inst "A"
    \repeat percent 8 { \makePercent s1 } \break

  R1*8 ^\markup { "Verse" } \segno
    \repeat percent 8 { \makePercent s1 } \break
  
  \inst "B"
  s1*0 ^\markup { "Chorus" } R1*16 | \break
  
  \inst "C" 
  \set Score.skipBars = ##t R1*8 ^\markup { "I want you back" } -\tweak self-alignment-X #-7 ^\markup { "Dal " \musicglyph "scripts.segno" " al " \musicglyph "scripts.coda" } \break
  
  \mark \markup { \musicglyph "scripts.coda" }
  R1 | \noBreak
  \inst "D"
  s1*0 ^\markup { "Brass 2" } R1*8 \break
  
  \inst "E"   
  s1*0 ^\markup { "Coro y Pregón 1" }
  R1*16  
    \break
 \repeat volta 2 {
   R1*8
 }

  \break
  
  \inst "F"     
   s1*0 ^\markup { "Sax Mambo" } |
  R1*8
    \inst "G" 
     s1*0 ^\markup { "Brass 3" }
  \repeat volta 2 {
  R1*6
  }
  \alternative {
  {
  R1*2
  }
  {
  R1*2
  }
  }
  \break
  
  \inst "H"    
  s1*0  ^\markup { "Coro y Pregón 2" }
  R1*32
  \break
  
  \inst "I"     
  s1*0 
  ^\markup { "Petas" }
  \repeat volta 2 {
  R1*7
  }
  \alternative {
    {
   R1
    }
    {
        R1
    }
  }
  \break
  
    \inst "J"
     
  s1*0  ^\markup { "Coro y Pregón 3" }
  R1*24
  \break

    \inst "K"
  s1*0 ^\markup { "Coda" } R1*8
  
  \label #'lastPage
  \bar "|."  
}

Chords = \chords {
  d 
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

\score {
  \unfoldRepeats {
    \Bass
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



