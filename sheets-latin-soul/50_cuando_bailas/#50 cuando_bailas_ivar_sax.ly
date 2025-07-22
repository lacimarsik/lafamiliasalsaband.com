\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#50 Cuando Bailas (Ivar: G)"
  instrument = "alto sax"
  composer = "by Leoni Torres"
  arranger = "Ladislav Maršík"
  opus = "version 27.8.2024"
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

Sax = \new Voice
\transpose c a'
\relative c {
  \set Staff.instrumentName = \markup {
    \center-align { "A. Sax in Eb" }
  }
  \set Staff.midiInstrument = "sax"
  \set Staff.midiMaximumVolume = #1.0

  \key g \major
  \time 4/4
  \tempo "Salsa" 4 = 180
  
       \inst "in"
  s1*0 ^\markup { "Keys Intro, bass on 1" }
  R1*8
  
  \inst "A1"

    s1*0 ^\markup { "Verso 1: Keys + perc" }
      R1*16 \break
        \inst "A2"
      s1*0 ^\markup { "Verso 2: Bass montuno + trumpet" }
      R1*3 |
      r2 b4 \p fis' |
      e2 d |
        c2 b2|
      b1 \> ~ |
      b1  |
      R1*2 \! 
      d2 e4 fis ~
      fis4 g2 r4 | 
      r4. fis,8 ~ fis4 g8 g |
      r2. r8 d' -- \mf |
      r b8 -- r2. |
      R1 \break
      

             \inst "B1" 
    s1*0 ^\markup { "Coro: Y es que solo tu" }
    R1       \segno |
    r2. r8 g \mf |
    r fis r d r a b4 \sp \< ~ |
    b2. r4 \! \mf |
    R1 |
    r2 r8 c d e |
    r d r c r b c4 \sp \< ~ |
    c2. r4 \mf \! |
    r2 c8 \mf c r4 | \break
    R1 |
    r4. d8 d d r4 |
    r2 r8 g,8 \mp a b |
    c4 b8 a4 g8 b4 ~ |
        b2 r8 g8 a b |
    c4 b8 a4 g8 b4 ~ |
    b2 r2 | \break
    b2 \mp \< ^\markup { "bass walks with trumpet" } a |
    b d4.  g8 \mf |
    r fis r b, r a b4 \sp \< ~ |
    b2. r4 \! \mf |
    R1 |
    r2 r8 c d e |
    r d r c r b c4 \sp \< ~ |
    c2. r4 \mf \! |
     r2 c8 \mf c r4 |
    r4. d8 d d r4 |
    r2 r8 g,8 \mp a b |
    c4 b8 a4 g8 b4 ~ |
        b2 r8 g8 a b |
    c4 b8 a4 g8 b4 ~ ^\markup { "to " \musicglyph "scripts.coda" } |  |
    b8 d \mf -- d r r2   | \break
    
   
                 \inst "A3" 
    s1*0 ^\markup { "Verso Accents: Como caída del cielo" }
    r4. d8 \mf g -> r a -> r |
    R1 |
      r4. d,8 g -> r a -> r |
    R1 |
        r4. g8 c -> r d -> r |
    R1 |
            r4. g,8 c -> r d -> r |
    R1 | \break
    r4. c8 -> r2 |
    r8 c8 -> r2. |
        r4. g8 -> r2 |
    r8 fis8 -> r2. |
             r4. g8 -> r2 |
              r8 g8 -> r2. |
                         r4. g8 -> r2 |
                         r2 
\tuplet 3/2 { b8 c cis} \tuplet 3/2 { d e fis } \break
g2 \bendAfter#-3 r2 |
            \inst "A4" 
    s1*0 ^\markup { "Verso: Quiero Darte" }
R1*8
r4 g,,8 \mf a g a g a |
g a r2. |
             4 g8 a g a g a |
a fis r2. |          
    R1*2 
    g'8 \f g g g, -> r2  |
    r8 g -- g -- r r2 ^\markup { "Dal " \musicglyph "scripts.segno" " al " \musicglyph "scripts.coda" }   | \break

\inst "C"
s1*0 ^\markup { "Metales" }
\mark \markup { \musicglyph "scripts.coda" }
    \grace {
      \hideNotes
      b1~
      \undo \hideNotes
    }
    
    b8 d \mf -- d -- r r4. b'8 |
    r g4 r8 r2  |
    r8 a a a a g r b |
    r g4 r8 r2 |
        r8 b b b b g r c  |
    r g4 r8 r2 |
          r8 b b b b g r c  |
    r g4 r8 r2 |
              r8 b b b b d r c  |
    r b r a r g e4 |
                  r8 b' b b b d r c  |
    r b r a r g a4 |
        r8 a a a a g r b |
    r g4 r8 r4. d8 |
            a' a a a a g r b |
    r ^\markup { "Dal" \musicglyph "scripts.segno" "1coro" }  g4  |  r8 r2  |
    
      \bar "|."
  \label #'lastPage
}

Chords =
\transpose es f'
\chords {
  \set noChordSymbol = ""

}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Sax
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