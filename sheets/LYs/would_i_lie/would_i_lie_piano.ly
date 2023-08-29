\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Would I Lie"
  instrument = "piano"
  composer = "by Cubaneros"
  arranger = "arr. Ladislav Maršík"
  opus = "version 7.9.2022"
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

upper = \new Voice \relative c'' {
  \set PianoStaff.instrumentName = \markup {
    \center-align { "Piano" }
  }
  \set Staff.midiInstrument = "piano"
  \set Staff.midiMaximumVolume = #0.7

  \clef treble
  \key c \minor
  \time 4/4
  \tempo "Fast Salsa" 4 = 210
  
  \set Score.skipBars = ##t R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { <c, c'>4 <c c'> <c c'> } \tuplet 3/2 { <es es'> <es es'> <es es'> } | 
  <g g'> r8 <c c'>8 <c c'>4 r |
  
  \inst "A"
  <es es'>8 ^\markup { "Chorus" } as c <c, c'> ~ <c c'> es as r |
  <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
  \ottava #1
  <f f'> as c <c, c'> ~ <c c'> f as r |
  <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
  <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
  <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
  <g g'> <bes es> ~ <bes es> <es, es'> ~ <es es'> <g bes> ~ <g bes> r |
  <g g'> <bes es> <f f'> <f f'> ~ <f f'> <es es'> ~ <es es'> <es es'> |
  
  <es es'>8 as c <c, c'> ~ <c c'> es as r |
  <es es'> as c <c, c'> ~ <c c'> <es es'> ~ <es es'> <e e'> |
  <f f'> as c <c, c'> ~ <c c'> f as r |
  <f f'> as c <c, c'> ~ <c c'> <f f'> ~ <f f'> <fis fis'> |
  <g g'> <c es> ~ <c es> <es, es'> ~ <es es'> <g c> ~ <g c> r |
  <g g'>4 <c es>8 <es, es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
  <g g'> <bes es> ~ <bes es> <f f'> ~ <f f'> <g bes> <f f'>4 |
  <bes, bes'> <es es'> ~ <es es'> \ottava #0 <c, f a> ~ |
  
  \inst "B"
  <c f a>1 ^\markup { "Verse 1" }  ~ |
  <c f a> |
  \makePercent s1
  
  <g'' bes es>4 <g bes d>4. r8 <f a c>4 ~ |
  <f a c>1 |
  \makePercent s1
  
  s1*0 ^\markup { "Improvisation" }
  \repeat percent 2 { \makePercent s1 }
  \repeat percent 3 { \makePercent s1 }
  
  <g, bes es>4 <g bes d>4. r8 <f a c>4 ~ |
  <f a c>1 |
  \makePercent s1
  s1*0 ^\markup { "Improvisation" }
  \repeat percent 2 { \makePercent s1 }
  \repeat percent 7 { \makePercent s1 }
  r2 <bes' bes'>8 -> <bes bes'> -> r4 |
  
  \inst "C"    
  s1*0 ^\markup { "Chorus" }
  \repeat volta 7 { \repeatBracket 7 { \makePercent s1*2 } }
  \makePercent s1 |
  \makePercent s2. \ottava #0 <c, f a>4 ~ |
  
  \inst "D"
  <c f a>1 ^\markup { "Verse 2" }  ~ |
  <c f a> |
  \makePercent s1
  
  <g' bes es>4 <g bes d>4. r8 <f a c>4 ~ |
  <f a c>1 |
  \makePercent s1
  s1*0 ^\markup { "Improvisation" }
  \repeat percent 2 { \makePercent s1 }
  \repeat percent 3 { \makePercent s1 }
  
  <g, bes es>4 <g bes d>4. r8 <f a c>4 ~ |
  <f a c>1 |
  \repeat percent 3 { \makePercent s1 }
  \inst "E"
  s1*0 ^\markup { "Swing!" }
  \repeat percent 3 { \makePercent s1*2 } 
  <as c es>1 |
  R1 |
  
  s1*0 ^\markup { "Chorus" }
  \repeat volta 8 { \repeatBracket 8 { \makePercent s1*2 } }
  
  \inst "F"
  \ottava #0
  s1*0  ^\markup { "Trombone solo" }
  \repeat volta 8 { \repeatBracket 8 { \makePercent s1*2 } }
  
  f'4 ^\markup { "Would I lie to you" } -> r2. |
  \ottava #0
  
  \set Score.skipBars = ##t R1*15
  
  \inst "G"
  s1*0 ^\markup { "Te digo" }
  <bes, bes'>8 r <bes bes'> r <bes bes'> r <bes bes'> r |
  <bes bes'>8 r <bes bes'> r <bes bes'> r <bes bes'> r |
  \repeat percent 6 { \makePercent s1 }
  \ottava #1
  <as' as'>8 -> <as as'> -> r4 <as as'>8 -> <as as'> -> r4 |
  \tuplet 3/2 { <as as'>4 -> <as as'> -> <as as'> -> } <as as'>8 -> r4. |
  
  \ottava #0
  s1*0 ^\markup { "Chorus" } |
  \repeat volta 4 { \repeatBracket 4 { \makePercent s1*2 } }
  
  \repeat percent 5 { \makePercent s1 }
  \makePercent s2. <f f'>4 -> ~ |
  <f f'>1 ~ |
  <f f'>2 r2 |
  
  \inst "H"
  \ottava #0
  r4 ^\markup { "Montuno - Petas" } <c c'>8 <es es'> ~ <es es'> <e e'> <as c> <f f'> |
  <f f'>4 <c c'>8 <es es'> ~ <es es'> <f f'> ~ <f f'> <fis fis'> |
  <g g'> <d d'> ~ <d d'> <f f'> ~ <f f'> <fis fis'> <b d> <g g'> |
  <g g'>4 <d d'>8 <f f'> ~ <f f'> <g g'> ~ <g g'> <bes bes'> |
  \ottava #1
  <c c'>8 <es g>8 ~ <es g> <bes bes'> <b b'> ~ <b b'> <es es'>4 |
  <c c'>4 <es g>8 <bes bes'> ~ <bes bes'> <es es'> ~ <es es'> <c c'> ~ |
  <c c'>8 <f a>8 ~ <f a> <bes, bes'> <b b'> ~ <b b'> <es es'>4 |
  <c c'>4 <f a>8 <bes, bes'> ~ <bes bes'> <b b'> ~ <b b'> <c c'> |
  
  \ottava #0
  \repeat percent 8 { \makePercent s1 } 
  
  \inst "I"
  \ottava #0
  s1*0 ^\markup { "Coro Pregón" }
  
  \repeat volta 16 { \repeatBracket 16 { \makePercent s1*2 } }
  
  R1 ^\markup { "Fade out" } |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  R1 |
  
  \set Score.skipBars = ##t R1*8 ^\markup { "A Capella" }
  
  
  \bar "|."  
}

lower = \new Voice \relative c {
  \set PianoStaff.instrumentName = \markup {
    \center-align { "Piano" }
  }
  \set Staff.midiInstrument = "piano"
  \set Staff.midiMaximumVolume = #0.7

  \clef bass
  \key c \minor
  \time 4/4
  
  \set Score.skipBars = ##t R1*14
  
  \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
  g r8 c8 c4 r |
  
  \clef treble
  
  es8 as c c, ~ c es as r |
  es as c c, ~ c es ~ es e |
  f as c c, ~ c f as r |
  f as c c, ~ c f ~ f fis |
  g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
  g4 <c es>8 es, ~ es f ~ f fis |
  g <bes es> ~ <bes es> es, ~ es <g bes> ~ <g bes> r |
  g <bes es> f f ~ f es ~ es es |
  
  es8 as c c, ~ c es as r |
  es as c c, ~ c es ~ es e |
  f as c c, ~ c f as r |
  f as c c, ~ c f ~ f fis |
  g <c es> ~ <c es> es, ~ es <g c> ~ <g c> r |
  g4 <c es>8 es, ~ es f ~ f fis |
  g <bes es> ~ <bes es> f ~ f <g bes> f4 |
  bes, es ~ es f4 ~ |
  
  f1 ~ |
  f1 |
  
  \makePercent s1
  
  g4 g4. r8 f4 ~ |
  f1 |
  
  \repeat percent 6 { \makePercent s1 }
  
  \clef bass
  g,4 g4. r8 f4 ~ |
  f1 |
  \repeat percent 10 { \makePercent s1 }
  r2 bes8 -> bes -> r4 |
  
  \clef treble
  \repeat volta 7 { \makePercent s1*2 }
 
  \makePercent s1 |
  \makePercent s2. f'4 ~ |
  f1 ~ |
  f1 |
  
  \makePercent s1
  
  g4 g4. r8 f4 ~ |
  f1 |
  
  \repeat percent 6 { \makePercent s1 }
  
  \clef bass
  g,4 g4. r8 f4 ~ |
  f1 |
  \repeat percent 3 { \makePercent s1 }
  \repeat percent 3 { \makePercent s1*2 }
  as1 |
  R1 |
  
  \clef treble
  \repeat volta 8 { \makePercent s1*2 }

  \repeat volta 8 { \makePercent s1*2 }


  f'4 -> r2. |
  
  \set Score.skipBars = ##t R1*15
  
  bes8 r bes r bes r bes r |
  
  bes8 r bes r bes r bes r |
  \repeat percent 6 { \makePercent s1 }
  
  as8 -> as -> r4 as8 -> as -> r4 |
  \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. |
  
  \repeat volta 4 { \makePercent s1*2 }
  
  \repeat percent 5 { \makePercent s1 }
  \makePercent s2. f4 -> ~ |
  f1 ~ |
  f2 r2 |
  
  \clef bass
  <es, as c>1 ~ |
  <es as c> |
  <b' d g> ~ |
  <b d g> |
  <c, es g bes> ~ |
  <c es g bes>2 <f a bes c> |
  <f a bes c>1 ~ |
  <f a bes c> |
  
  \repeat percent 5 { \makePercent s1 }
  \makePercent s2 <f a bes c>4 \tenuto <f a bes c> \tenuto |
  <f a bes c>1 ~ |
  <f a bes c> |
  
  \repeat volta 16 { \makePercent s1*2 }
  
  <es as c>1 ~ |
  <es as c> |
  <b' d g> ~ |
  <b d g> |
  <c, es g bes> ~ |
  <c es g bes>1 |
  <f a bes c>1 ~ |
  <f a bes c> |
  
  \clef treble 
  <c' es f as>1 ~ |
  <c es f as> |
  <d f g> ~ |
  <d f g> |
  \clef bass
  <g, as c es> ~ |
  <g as c es> |
  <f a bes c>1 ~ |
  <f a bes c> |
  
  \label #'lastPage
  \bar "|."  
}

Chords = \chords {
  R1*16

  as1 | as | f:m | f:m |
  c:m | c:m |
  es | es |
  as1 | as | f:m | f:m |
  c:m | c:m |
  es | es |

  
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  bes | bes | f | f |
  g | g | as | as |
  
  \repeat volta 7 {\makePercent s1 | \makePercent s1 } 
  
  es | es |
  
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  f | f | f | f |
  
  
  bes | bes | f | f |
  g | g | as | as |
  
  \repeat volta 8 { \makePercent s1 | \makePercent s1 } 
  
  \repeat volta 8 { \makePercent s1 | \makePercent s1 } 
  f | r1*7 | r1*8
  
  bes1 | bes | f/a | f/a |
  g | g | as | as |
  as | as |
  
  \repeat volta 4 { \makePercent s1 | \makePercent s1 } 
  
  as1 | as | f:m | f:m |
  c:m | c:m |
  f | f |  
  
  as | as | g | g |
  c:m | c:m | f | f |
  as | as | g | g |
  c:m | c:m | f | f |
  
  \repeat volta 16 { \makePercent s1 | \makePercent s1 } 
  
  as | as | g | g |
  c:m | c:m | f | f |
  as | as | g | g |
  c:m | c:m | f | f |
}

\score {
  <<
    \Chords
    \compressMMRests \new PianoStaff \with {
      \consists "Volta_engraver"
    }
    {
      <<
        \new Staff = "upper" \upper
        \new Staff = "lower" \lower
      >>
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
      \on-the-fly #print-page-number-check-first
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
      \on-the-fly #print-page-number-check-first
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
    }
  }
}