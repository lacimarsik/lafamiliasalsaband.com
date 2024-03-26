\version "2.18.2"

\header {
    title = "Létám 2"
    composer = "Elinor"
    arranger = "La Familia Salsa Band"
    instrument = "Saxophone"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Saxophone = \new Voice
\transpose c a,
\relative c'' {
    \set Staff.instrumentName = \markup {
	\center-align { "Sax in Eb" }
    }
    \set Staff.midiInstrument = "alto sax"
    \set Staff.midiMaximumVolume = #1.0

    \key d \minor
    \time 4/4
    \tempo "Andante" 4 = 120

    \set Score.skipBars = ##t R1 ^\markup { "Percuss. intro" }
    
    r4. a8 f'4 e8 es ~ |
    es4.g8 d4 \grace { es8 d } c8 f ~ |
    f4. d8 c4 bes8 a ~ |
    a4 g8 a bes4 c8 a |
    a4 r8 d \tuplet 3/2 { f4 g a ~ }
    a4. d8 \tuplet 3/2 { c4 \grace { g8 } a4 f ~ } |
    f4. d8 f g f a ~ |
    a1 |
    
     
    \bar "|."
}

\score {
  \new Staff {
	\new Voice = "Saxophone" {
		\Saxophone			
	}
  }
  \layout {
  }
}

\score {
    \unfoldRepeats {
        \new Staff {
	      \new Voice = "Saxophone" {
		      \Saxophone			
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