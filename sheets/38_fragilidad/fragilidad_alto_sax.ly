\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#38 Fragilidad (La Familia: Hmi)"
  instrument = "sax"
  composer = "by Sting / RDM cover"
  arranger = "Ladislav Maršík"
  opus = "version 23.4.2025"
    copyright = "© La Familia Salsa Band 2025"
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
\transpose c a
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Alto Sax" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #1.0

  \key b \minor
  \time 4/4
  \tempo "Slow Salsa" 4 = 170
  
       \inst "in"
       \repeat volta 2 {
  s1*0 ^\markup { "Intro (1st: sax solo, trumpet+sax+bone, D.C.: piano+guitar then t+s+b)" }
<fis a,>2 ~ <fis a,>8 <e g,> ~ <e g,> <d fis,> ~ |
<d fis,> <d fis,> ~ <d fis,> <fis a,> ~ <fis a,> <fis a,> ~ <fis a,> r8 |
<d fis,>2 ~ <d fis,>8 <cis e,> ~ <cis e,> <b d,> ~ |
<b d,> <b d,> ~ <b d,> <d fis,> ~ <d fis,> <d fis,> ~ <d fis,> r8 |
<d fis,>2 ~ <d fis,>8 <cis e,> ~ <cis e,> <b d,> ~ |
<b d,> <b d,> ~ <b d,> <ais cis,> ~ <ais cis,> <ais cis,> ~ <ais cis,> r8 |
       }
\alternative { {
<cis e,>2 ~ <cis e,>8 <b d,> ~ <b d,> <d fis,> ~ |
<d fis,> r8 r2. |
} {
  <cis e,>2 ~ <cis e,>8 <d fis,> ~ <d fis,> <b d,> ~ |
<b d,> r8 r2. | 
\break
} }
        \inst "A1,2"
    s1*0 ^\markup { "Verse 1 & 2" }
      R1*16 \break
            \inst "B1,2"
          s1*0 ^\markup { "Pre-Chorus 1 & 2" }
      R1*16 \break
            \inst "C1,2"
                s1*0 ^\markup { "Chorus 1 & 2" } 
    \repeat volta 2 {
    R1
     r8 d' -> r b -> r g -> r e |
     fis4 -> a g4. d'8 -> ~ \< |
     d1 |
     cis8 -. \sp r r4 r8 fis,8 r4 |
     a8 -> r g fis r d cis b |
     r2 b2 ( \< |
     d fis ) \! ^\markup { "2va D.C. Al Fine" } |

      \break 
    }
      R1*32 \fermata ^\markup { "Forma: SOLO 1 brass (open), 2x Chorus (play C 4 repeats), 4x ending Que Fragilidad" } \break
   \break
                   

\chordmode {
     e1:m  _\markup { "solo chords" }  |
    e1:m |
fis1 ~ |
   fis1 |
   b,1:m ~ |
   b,1:m  |
   b,1:m ~ |
   b,1:m |
}

  \label #'lastPage
    \bar "|."
}

Chords =
\transpose c a
\chords {
  \set noChordSymbol = ""
  R1*82
     e1:m |
    e1:m |
fis1 ~ |
   fis1 |
   b1:m ~ |
   b1:m  |
   b1:m ~ |
   b1:m |
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \AltoSax
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