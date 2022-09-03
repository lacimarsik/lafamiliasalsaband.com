\version "2.18.2"

\header {
    title = "4. Létám"
    composer = "Elinor"
    arranger = "La Familia Salsa Band"
    instrument = "Bass"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

makePercent =
    #(define-music-function (parser location note) (ly:music?)
       (make-music 'PercentEvent
                   'length (ly:music-length note)))
    
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

Bass = \new Voice \transpose d c \relative c {
    \set Staff.instrumentName = \markup {
        \center-align { "Bass" }
    }
    \set Staff.midiInstrument = "electric bass (finger)"
    \set Staff.midiMaximumVolume = #1.0

    \clef bass
    \key e \minor
    \time 4/4
    \tempo "Andante" 4 = 120

    s1*0 ^\markup { "Intro" }
    \makePercent s1 |
    \makePercent s1 |
    \compressPercentRepeat #3 { \makePercent s1  } |
    
    r8 b -. b -. b -. b4 -. b -. |
    
    s1*0 ^\markup { "Verse 1" }
    \repeat volta 2 {
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
    }
    \alternative {
      {
        \makePercent s1 |
      }
      {
        b4 b2 r4 | \break
      }
    }

    s1*0 ^\markup { "Chorus" }
    \repeat volta 2 {
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
    }
    s1*0 ^\markup { "Bass" }
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \break
    
    s1*0 ^\markup { "Verse 2" }
    \repeat volta 2 {
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
    }
    \alternative {
      {
        \makePercent s1 |
      }
      {
        b4 b2 r4 | \break
      }
    }

    s1*0 ^\markup { "Chorus" }
    \repeat volta 2 {
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
    }
    
    s1*0 ^\markup { "Solo" }
    \makePercent s1 |
    \makePercent s1 |
    \compressPercentRepeat #10 { \makePercent s1  } | \break
    
    s1*0 ^\markup { "Intro" }
    \makePercent s1 |
    \makePercent s1 |
    \compressPercentRepeat #3 { \makePercent s1  } |
    
    r8 b -. b -. b -. b4 -. b -. |
    
    s1*0 ^\markup { "Verse 3" }
    \repeat volta 2 {
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
        \makePercent s1 |
    }
    \alternative {
      {
        \makePercent s1 |
      }
      {
        b4 b2 r4 | \break
      }
    }
    
    s1*0 ^\markup { "Chorus" }
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    e'2 b2 |
    e,4 e2. |
    
    s1*0 ^\markup { "Bridge" }
    \repeat volta 4 {
        \makePercent s1 |
        \makePercent s1 |
    }
    \alternative {
      {
         \makePercent s1 |
          b4 b2. | 
      }
      {
          \makePercent s1 |
          d1 |
      }
    }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Chorus A CAPELLA" }
    
    s1*0 ^\markup { "Chorus" }
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    
   
    s1*0 ^\markup { "Outro" }
    \makePercent s1 |
    \makePercent s1 |
    \compressPercentRepeat #3 { \makePercent s1  } |
    
    \bar "|."
}

Chords = \chords {
    d1:m | g2:m a:m |
    \set Score.skipBars = ##t R1*3
    d1:m | d1:m | g1:m | a1:m | 
    d1:m | d1:m | g1:m | a1:m | 
    a1:m |
    d1:m | f1 | g1:m | a1:m | 
    d1:m | f1 | g1:m | a1:m | 
    d1:m | d1:m | g1:m | a1:m | 
    d1:m | d1:m | g1:m | a1:m | 
    d1:m | d1:m | g1:m | a1:m | 
    a1:m |
    d1:m | f1 | g1:m | a1:m | 
    d1:m | f1 | g1:m | a1:m | 
    d1:m | g2:m a:m |
    \set Score.skipBars = ##t R1*9
    d1:m | g2:m a:m |
    \set Score.skipBars = ##t R1*3
    d1:m | d1:m | g1:m | a1:m | 
    d1:m | d1:m | g1:m | a1:m | 
    a1:m |
    d1:m | f1 | g1:m | a1:m | 
    d1:m | f1 | g1:m | a1:m | 
    d1:m | d1:m |
    a1:m | bes1 | d2:m g2:m | a1:m |
    c1 | c1 |
    \set Score.skipBars = ##t R1*8
    d1:m | f1 | g1:m | a1:m | 
    d1:m | f1 | g1:m | a1:m | 
    d1:m | g2:m a:m |
    \set Score.skipBars = ##t R1*3
    
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
	between-system-padding = #2
	bottom-margin = 5\mm
}