\version "2.18.2"

\header {
    title = "Baila Conmigo"
    composer = "Saned Rivera"
    arranger = "Ladislav Maršík"
    instrument = "structure"
    copyright = "© La Familia Salsa Band 2018"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Flute = \new Voice \relative c'' {
    \set Staff.instrumentName = \markup {
        \center-align { "Structure" }
    }

    \key c \major
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \set Score.skipBars = ##t R1*10 ^\markup { "A - Intro" }
    \set Score.skipBars = ##t R1*16 ^\markup { "B - Baila" }
    \set Score.skipBars = ##t R1*16 ^\markup { "C - Se siente" } \break
    
    \set Score.skipBars = ##t R1*16 ^\markup { "D - Baila" }
    \set Score.skipBars = ##t R1*16 ^\markup { "E - Uno dos" }
    \set Score.skipBars = ##t R1*16 ^\markup { "F - Baila" } \break
    
    \set Score.skipBars = ##t R1*24 ^\markup { "G - Bridge" }
    \set Score.skipBars = ##t R1*24 ^\markup { "H - Yo quiero bailar" }
    
    \set Score.skipBars = ##t R1*16 ^\markup { "I - Mambo (Yo quiero bailar)" }
    
    \set Score.skipBars = ##t R1*22 ^\markup { "J - Baila" } \break
    
    \bar "|."
}

\score {
    \new Staff {
        \new Voice = "Flute" {
            \Flute			
        }
    }
    \layout {
    }
}

\score {
    \unfoldRepeats {
        \new Staff {
            \new Voice = "Flute" {
                \Flute
            }
        }
    }
    \midi {
    }
}

\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}