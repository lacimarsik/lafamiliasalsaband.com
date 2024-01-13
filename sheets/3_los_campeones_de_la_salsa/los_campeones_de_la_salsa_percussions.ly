\version "2.10.33"

\header {
		title = "Los Campeones de la Salsa"
		composer = "Willy Chirino"
		arranger = "Ladislav Maršík"
		instrument = "percussions"
		copyright = "© La Familia Salsa Banhh 2016"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Percussions = \drummode {
        \set Staff.instrumentName = \markup {
	    \center-align { "Percussions" }
	}

	\time 4/4
	\tempoMark "Moderato"
	\tempo 4 = 180

	\set Score.skipBars = ##t R1*2 ^\markup { "Sirens" }
	
	hh4 ^\markup { "Intro" } \f r2. |
	hh8 r r hh r2 |
	hh4 r2. |
	hh8 r r hh r2 |
	hh4 r2 hh4 |
	hh4 r2 hh4 |
	hh4 r2 hh4 |
	r8 hh hh hh hh hh hh hh |
	\set Score.skipBars = ##t R1*6 ^\markup { "(tumbao)" }
        hh4 ^\markup { "(tumbao)" } r2. |
	sn8 r r sn r r bd r |
	hh8 hh hh hh hh r r4 |
	bd8 r r bd r r bd r | \break

	\set Score.skipBars = ##t R1*7 ^\markup { "Chorus (tumbao)" }
	r8 bd r bd bd r sn sn |
	\set Score.skipBars = ##t R1*7 ^\markup { "(tumbao)" }
	r2 tomh16 ^\markup { "(timbal)" } tomh tomh r r4 |
	hh4 ^\markup { "Piano Break" } -> r r2 |
	r2 r8 bd r sn |
	R1 |
	r8 hh hh hh hh hh hh hh |
	\set Score.skipBars = ##t R1*14 -\! ^\markup { "Verse 1 (tumbao)" }
        bd8 bd r r bd r r bd  |
        r4 r8 hh hh4 hh4 -. | \break
          
        \set Score.skipBars = ##t R1*7 ^\markup { "Chorus (tumbao)" }
	r8 bd bd bd bd bd bd r |
	\set Score.skipBars = ##t R1*7 ^\markup { "(tumbao)" }
	r2. r8 hh16 hh |

	hh4 ^\markup { "Piano Break" } -> r r2 |
	r2 r8 bd r sn |
	R1 |
	r8 hh hh hh hh hh hh hh |
	\set Score.skipBars = ##t R1*14 -\! ^\markup { "Verse 2 (tumbao)" }
        bd8 bd r r bd r r bd  |
        r4 r8 hh hh4 hh4 -. | \break
        
        \set Score.skipBars = ##t R1*7 ^\markup { "Chorus (tumbao)" }
	r8 bd bd bd bd r bd r |
	\set Score.skipBars = ##t R1*6 ^\markup { "(tumbao)" }
	r2 r8 tomh8 ^\markup { "(bell)" } tomh tomh |
	tomh tomh tomh tomh tomh tomh tomh r | \break
	
	\set Score.skipBars = ##t R1*14 ^\markup { "Intro (tumbao)" }
	hh4 \f hh hh hh |
	tomh16 \mp ^\markup { "(percussions)" } tomh tomh r tomh8 tomh tomh16 tomh tomh r tomh8 tomh16 tomh |
	hh4 \f hh hh hh8 tomh16 ^\markup { "(timbal)" } tomh |
	tomh8 hh -> r hh -> r2 | \break

	\set Score.skipBars = ##t R1*16 ^\markup { "E se soy yo (tumbao)" }

	\set Score.skipBars = ##t R1*8 ^\markup { "Trumpet Bridge (tumbao)" }

	\set Score.skipBars = ##t R1*16 ^\markup { "REGGAETON" } \break

	\set Score.skipBars = ##t R1*7 ^\markup { "E se sel mio (no perc.)" }

	tomh8 ^\markup { "(bell)" } tomh tomh tomh tomh tomh tomh tomh |
	
	\set Score.skipBars = ##t R1*8 ^\markup { "(tumbao)" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus (tumbao)" } \break
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet (tumbao)" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Saxophone (tumbao)" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus (tumbao)" } \break
	
	hh4 ^\markup { "Intro" } \f r2. |
	hh8 r r hh r2 |
	hh4 r2. |
	hh8 r r hh r2 |
	hh4 r2 hh4 |
	hh4 r2 hh4 |
	hh4 r2 hh4 |
	r8 hh hh hh hh hh hh hh |
	\set Score.skipBars = ##t R1*6 ^\markup { "(tumbao)" }
        hh4 ^\markup { "(tumbao)" } r2. |
	sn8 r r sn r r bd r |
	hh8 hh hh hh hh r r4 |
	bd8 r r bd r r bd r | \break
	
	hh8 ^\markup { "Coda" } hh hh hh hh4 hh4 |
	
	\time 5/4
	tommh16 ^\markup { "(timbal)" }
	\mark \markup { \bold "5 beats = 2 bars" } r tomh tomh
	tommh r tomh tomh 
	tommh r tomh tomh 
	tommh r tomh tomh 
	tommh r tomh tomh |
	\time 4/4
	hh8 \ff
	\mark \markup { \bold "a tempo" }
	hh hh hh hh4 r |
	
	\bar "||"
}


\score {
    \new DrumStaff <<
        \Percussions	
    >>
    \layout {
    }
}

\score {
    \unfoldRepeats {
        \new DrumStaff <<
            \Percussions	
        >>
    }
    \midi {
    }
}

\paper {
	% between-system-space = 10\mm
	between-system-paddinhh = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}

