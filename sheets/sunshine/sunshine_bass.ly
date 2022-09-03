\version "2.19.83"

\header {
    title = "12. Sunshine"
    composer = "Williamsburg Salsa Orchestra"
    arranger = "Ladislav Maršík"
    instrument = "bass"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

makePercent = #(define-music-function (note) (ly:music?)
   (make-music 'PercentEvent 'length (ly:music-length note)))

compressPercentRepeat =
#(define-music-function (repeats notes) (integer? ly:music?)
    (let* (
       (mea (ly:music-length notes))
       (num (ly:moment-main-numerator mea))
       (den (ly:moment-main-denominator mea))
       (dur (ly:make-duration 0 0 (* num (1- repeats)) den)))
        #{
            \set Score.restNumberThreshold = #1
            \set Score.skipBars = ##t
            \temporary\override MultiMeasureRest.stencil = #ly:multi-measure-rest::percent
            \temporary\override MultiMeasureRestNumber.stencil =
                  #(lambda (grob)
                       (grob-interpret-markup grob
                         (markup #:concat
                         ( ;; Optional:
                           ;#:fontsize -3 "x"
                           #:fontsize -2 (number->string repeats)))))
            \temporary\override MultiMeasureRest.thickness = #0.48
            \temporary\override MultiMeasureRest.Y-offset = #0
            #(make-music 'MultiMeasureRestMusic 'duration dur)
            \revert MultiMeasureRest.Y-offset
            \revert MultiMeasureRest.thickness
            \revert MultiMeasureRestNumber.stencil
            \revert MultiMeasureRest.stencil
            \unset Score.skipBars
            \unset Score.restNumberThreshold
        #}))

Bass = \new Voice \relative c, {
    \set Staff.instrumentName = \markup {
      \center-align { "Bass" }
    }
    \set Staff.midiInstrument = "acoustic bass"
    \set Staff.midiMaximumVolume = #1.5

    \clef bass
    \key gis \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    
    fis8 ^\markup { "Break 1" } fis fis fis r fis fis r |
    
    \repeat volta 2 {
        s1*0 ^\markup { "Intro" } \repeat percent 8 { \makePercent s1 } | \break
    }
    
    \repeat volta 2 {
        s1*0 ^\markup { "Intro Brass" } \repeat percent 8 { \makePercent s1 } | \break
    }
    
    R1 ^\markup { "Sunshine" } |
    gis4. gis4. fis4 -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) |
    
    \repeat percent 6 { \makePercent s1 } |
    \repeat percent 8 { \makePercent s1 } | \break
    
    s1*0 ^\markup { "Verse 1 - No piano" }
    \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
    \repeat percent 8 { \makePercent s1 } | \break
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    R1 ^\markup { "Sunshine" } |
    gis4. gis4. fis4 -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) |
    \repeat percent 6 { \makePercent s1 } |
    \repeat percent 8 { \makePercent s1 } | \break
    
    r4 ^\markup { "Break 2" } dis'8 dis dis dis r dis |
    r dis r dis dis r4. |
    \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
    s1*0 ^\markup { "Verse 2 - Softer + Gradation" }
    \repeat percent 8 { \makePercent s1 } | \break
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    R1 ^\markup { "Sunshine" } |
    gis,4. gis4. fis4 -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) |
    \repeat percent 6 { \makePercent s1 } |
    \repeat percent 6 { \makePercent s1 } | \break
    r4 ^\markup { "Break 3" } dis'8 dis dis dis r fis |
    r dis r cis r b r ais |
    gis r dis' r gis, dis' r b |
    r fis' r dis g g r gis | 
    \repeat volta 2 {
        s1*0 ^\markup { "Trombone solo" } \repeat percent 8 { \makePercent s1 } |
    }
    \repeat volta 2 {
        s1*0 ^\markup { "I can fly" } \repeat percent 8 { \makePercent s1 } | \break
    }
    
    s1*0 ^\markup { "Montuno" }
    \set Score.repeatCommands = #(list(list 'volta "1.-3.") 'start-repeat)
    \repeat percent 8 { \makePercent s1 } | \break
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    gis4 -. ^\markup { "Break 4" } gis -. r8 b ~ b r |
    cis8 -. r4 d8 -. r4 dis, ~ |
    dis1 |
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*6 ^\markup { "Verse 3" }
    }
    \alternative {
      {
         \set Score.skipBars = ##t R1*2
      }
      {
         fis4 r fis r |
         fis4 r fis r | \break
      }
    }
    \repeat volta 2 {
         \repeat percent 8 { \makePercent s1 } | \break
    }
    \set Score.skipBars = ##t R1*2 ^\markup { "We can live together" }
    R1 ^\markup { "Sunshine" } |
    gis,4. gis4. fis4 -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) |
    \repeat percent 6 { \makePercent s1 } | \break
    \repeat volta 3 {
        \repeat percent 6 { \makePercent s1 } |
    }
    \alternative {
      {
         \repeat percent 2 { \makePercent s1 } |
      }
      {
        r4 ^\markup { "Break 3 + Coda" } dis'8 dis dis dis r fis |
        r dis r cis r b r ais |
      }
    }
    gis r dis' r gis, dis' r b |
    r fis' r dis g g r gis ~ |
    gis1 |
    
    \bar "|."  
}

Chords = \chords {
    R1 |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1 | R1 | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1 | R1 | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1 | R1 |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1 | R1 | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | R1 | R1 |
    R1 | R1 |
    gis:m | gis:m | gis:m | gis:m |
    gis:m | gis:m | gis:m | gis:m |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    gis:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1*13
    gis1:m | gis:m | fis | fis |
    e | e | fis | fis |
    R1 | R1 |
    R1 | R1 | fis | fis |
    e | e | fis | fis |
    gis1:m | gis:m | fis | fis |
    e | e | fis | fis |
}

\score {
  <<
    \Chords
    \new Staff \with {
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
	% between-system-space = 10\mm
	between-system-padding = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}