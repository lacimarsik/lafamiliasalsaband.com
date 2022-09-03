\version "2.18.2"

\header {
    title = "Yo No Se Mañana"
    composer = "Luis Enrique"
    arranger = "Ladislav Maršík"
    instrument = "saxophone"
    copyright = "© La Familia Salsa Band 2018"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Saxophone = \new Voice \transpose c g \transpose c a \relative c {
  \set Staff.instrumentName = \markup {
		\center-align { "Sax in Es" }
	}

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

		g'1 ~ |
		g1 |
		
		\set Score.skipBars = ##t R1*5
		
		f4 _\markup { \italic "cresc." } g bes c |

		bes4 -\accent -\f ^\markup { "Chorus" } r4 r2 |

		r1 |
		r4. g4. -> g8 -. r8 |

		r1 |
		r4. f4. -> f8 -. r8 |

		R1 |
		c1 ( \sp ~ \< |
		c1 |
		bes8 ) \> r4 \! c'8 c8 c8 r4 |
		r4. c8 c8 c8 r4 |
		r4. c8 c8 c8 r4 |

		r4. c8 c8 c8 r4 |
		r4. bes8 bes8 bes8 r4 |
		r4. bes8 bes8 bes8 r4 |

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
			r4. bes8 ~ bes4 bes8 r8 |
			r4. bes8 ~ bes4 bes8 r8 |
			r4. bes8 ~ bes4 bes8 r8 |
			f'4 -- -\f  ( g -- c, -- es -- ~ |
		}
	}
        
        es ^\markup { "Bridge 1" } ) r4 r2 |
        
        \set Score.skipBars = ##t R1*2
        
        f,4 \p -- ( g -- bes, -- d -- ~ |
        d1 ~ \< |
        d2 \mf ) r |
        
        R1 |
        
        f'4 \f -- ( g -- c, -- es -- ~ |
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
        \repeat volta 4 {
            g,8 -- ^\markup { "Bridge 2 (4x repeat)" } g4 -. g8 -> r g ( fis fis -. ) |
            r fis -. r fis ( a a -. ) r a -> |
            r a ( g g -. ) r g -> r4 |
        }
        \alternative {
            {
                f4 -- g -- bes -- d -- |
            }
            {
                f,4 -\f -- g -- bes -- c -- |
            }
        }

        r8 d4 -> r8 r2 |
        \set Score.skipBars = ##t R1*7 ^\markup { "Yo no se, Yo no se manana" }
        \set Score.skipBars = ##t R1*8

        r4. ^\markup { "Yo no se, Yo no se" } c,8 \f -. r d g4 ~ |
        g2 a2 |
        r2 r8 d, a'4 ~ |
        a2 bes2 |
        r4. c,8 -. r d g4 ~ |
        g2 a2 |
        r4. a8 ~ a4 \accent r4 |
        R1 |
        \set Score.skipBars = ##t R1*2 ^\markup { "Chorus" }
        r4. g4. -> g8 -. r8 |

		r1 |
		r4. f4. -> f8 -. r8 |

		R1 |
		c'1 ( \sp ~ \< |
		c1 |
		bes8 ) \> r4 \! c8 c8 c8 r4 |
		r4. c8 c8 c8 r4 |
		r4. c8 c8 c8 r4 |

		r4. c8 c8 c8 r4 |
		r4. bes8 bes8 bes8 r4 |
		r4. bes8 bes8 bes8 r4 |

		r2 a4. g8 ~ |
		g4 r2. |
        \set Score.skipBars = ##t R1*2
        
        es'4 \tenuto \f f4 \tenuto  r2 |
    
    \bar "|."
}

\score {
  \new Staff {
	\new Voice = "Sax" {
		\Saxophone			
	}
  }
  \layout {
  }
}

\score {
    \unfoldRepeats {
        \new Staff {
	      \new Voice = "Sax" {
		      \Saxophone			
	      }
        }
    }
    \midi {
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