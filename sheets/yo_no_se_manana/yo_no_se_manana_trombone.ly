\version "2.22.2"

\header {
    title = "Yo No Se Mañana"
    composer = "Luis Enrique"
    arranger = "Ladislav Maršík"
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2022"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Trombone = \new Voice \transpose c g \relative c {
  \set Staff.instrumentName = \markup {
		\center-align { "Trombone" }
	}

        \clef bass
        \key bes \major
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Piano" }
	
	\set Score.skipBars = ##t R1*15 ^\markup { "Verse 1" }

	r2 r4 bes4 -\p ~ |

	\repeat volta 2 {
		bes1 ~ ^\markup { "Verse 2 & 3" } |
		bes1 |
		r1 |
		c1 ~ |

		c1 ~ |
		c2 d2 |
		c1 ~ |
		c2 r2 |

		bes1 ~ |
		bes1 |
		
		\set Score.skipBars = ##t R1*5
		
		f4 _\markup { \italic "cresc." } g4 bes2 |

		bes4 -\accent -\f ^\markup { "Chorus" } r4 r2 |

		r1 |
		r4. bes4. -> bes8 -. r8 |

		r1 |
		r4. bes4. -> bes8 -. r8 |

		R1 |
		f'1 ( \< ~ |
		f1 |

		es8 ) \> r4 \! es8 es8 es8 r4 |
		r4. es8 es8 es8 r4 |
		r4. es8 es8 es8 r4 |

		r4. es8 es8 es8 r4 |
		r4. d8 d8 d8 r4 |
		r4. d8 d8 d8 r4 |

		r2 a4. g8 ~ |
		g4 r2. |

		\set Score.skipBars = ##t R1*4
	}
	\alternative {
		{
			\set Score.skipBars = ##t R1*3
			r2 r4 bes4 -\p \laissezVibrer |
		}
		{
			r4. g8 ~ g4 f8 r |
			r4. g8 ~ g4 f8 r |
			r4. g8 ~ g4 f8 r |
			f'4 -- -\f ( g -- c, -- es -- ~ |
		}
	}
	
        es ^\markup { "Bridge 1" } ) r4 r2 |
        
        \set Score.skipBars = ##t R1*6
        
        f4 -- ( g -- c, -- es -- ~ |
        es ) r4 r2 |
        
        \set Score.skipBars = ##t R1*3
        
        r4. c8 -. -\mp r c -. c4 -- ~ |
        c4. c8 -. r bes c4 -- ~ |
        c4. c8 -\mf -> ~ c4 r |
        R1 | \break
        r2. f4 -\f ( |
        f g bes g |
        bes4. bes8 -. ~ bes4 ) r |
        R1 |
        r2. f4 ( |
        f g bes g |
        bes4. bes8 -. ~ bes4 ) r |
        R1 |
        
        \repeat volta 2 {
            \set Score.skipBars = ##t R1*7
        }
        \alternative {
            {
                R1 | \break
            }
            {
                f,4 -- -\mf g -- bes -- d -- |
            }
        }
        \repeat volta 2 {
            c8 -- ^\markup { "Bridge 2" } c4 -. c8 -> r b ( c c -. ) |
            r c -. r b ( c c -. ) r c -> |
            r b ( c c -. ) r c -> r4 |
        }
        \alternative {
            {
                f,4 -- g -- bes -- d -- |
            }
            {
                f,4 -\f -- g -- bes -- c -- |
            }
        }
        r8 d4 -> r8 r2 |
        \set Score.skipBars = ##t R1*7 ^\markup { "Yo no se, Yo no se manana" }
        \set Score.skipBars = ##t R1*8

        \set Score.skipBars = ##t R1*8 ^\markup { "Yo no se, Yo no se" }

        
        \set Score.skipBars = ##t R1*2 ^\markup { "Chorus" }
        r4. bes4. -> bes8 -. r8 |

		r1 |
		r4. bes4. -> bes8 -. r8 |

		R1 |
		f'1 ( \< ~ |
		f1 |

		es8 ) \> r4 \! es8 es8 es8 r4 |
		r4. es8 es8 es8 r4 |
		r4. es8 es8 es8 r4 |

		r4. es8 es8 es8 r4 |
		r4. d8 d8 d8 r4 |
		r4. d8 d8 d8 r4 |

		r2 a4. g8 ~ |
		g4 r2. |
        
        \set Score.skipBars = ##t R1*2
        
        es'4 \tenuto \f f4 \tenuto  r2 |
    
    \bar "|."
}

\score {
  \new Staff {
	\new Voice = "Trombone" {
		\Trombone			
	}
  }
  \layout {
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