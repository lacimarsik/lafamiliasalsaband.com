\version "2.10.33"

\header {
		title = "Los Campeones De La Salsa"
		composer = "Willy Chirino"
		arranger = "Ladislav Maršík"
		instrument = "saxophone"
		copyright = "© La Familia Salsa Band 2016"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

scoopMusic = \relative 
{ 
     \override BendAfter #'rotation = #'(-45 -4 3) 
     \override Score.SpacingSpanner #'shortest-duration-space = #4.0   
} 

Sax = \new Voice \transpose es, c \relative c' {
        \set Staff.instrumentName = \markup {
		\center-align { "Sax in Eb" }
	}

	\key c \minor
	\time 4/4
	\tempoMark "Moderato"
	\tempo 4 = 180

	c8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es f4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	g8 -\f g g g g4 -. r |
	R1 |
	g8 -\ff g g g g4 -> r8 c, \mp | 
	d -. r d b -. r b b -. r | \break
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	    g2. ~ g8 g'8 ~ -> |
	    g g f g f g16 f es4 -. |
	    c4 -> r r r8 c8 -. |
	    r4 r8 c d es4. |
	    c4 -. r r2 |
	    r4. c8 d es d es -. |
	    \set Score.skipBars = ##t R1*2
	    g,2. ~ g8 des'8 ~ -> |
	    des des4 -. es -. des4. |
	    c4 -> ^\markup { "Piano Break" } r r2 |
	    r2 r8 des4 -. es8 -\sfz -\< ~ |
	    es1 ~ |
	    es1 \ff |
	    \set Score.skipBars = ##t R1*14 ^\markup { "Verse 1 and 2" } | 
            r8 g -> -. r4 g -> -. r8 g -> -. |
            r4 r8 g -> g4 -> g4 -> -. | \break
	}
	\set Score.currentBarNumber = 93
	
	\set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	g,2. ~ g8 g'8 ~ -> |
	g g f g f g16 f es4 -. |
	c4 -> r r r8 c8 -. |
	r4 r8 c d es4. |
	c4 -. r r2 |
	r4. c8 d es d es -. |
	\set Score.skipBars = ##t R1*2
	g,2. ~ g8 des'8 ~ -> |
	des des4 -. es -. des4. | \break
	
	c8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es g4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	as4 -. as -. as -. as -. |
	R1 |
	g4 -. g -. g -. g -. |
	r8 g4 -. as8 -> ~ as4 \bendAfter #-4 r4 | \break

	\set Score.skipBars = ##t R1*16 ^\markup { "E se soy yo" }
	
	\set Score.skipBars = ##t R1*8 ^\markup { "Trumpet" }

	\set Score.skipBars = ##t R1*16 ^\markup { "Reggaeton" } \break

	\set Score.skipBars = ##t R1*16 ^\markup { "E se sel mio" }

	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Saxophone" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus" } \break
	
	c,8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es g4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	g8 -\f g g g g4 -. r |
	R1 |
	g8 -\ff g g g g4 -> r8 c, \mp | 
	d -. r d b -. r b b -. r | \break
	c8 \ff ^\markup { "Coda" } c c c es4 -> c -> -. |
	R1 ^\markup { "5 = 2 bars" } |
	R1 |
	c8 \fff c c c -> -. r2 | 
	
	\bar "||"
}


\score {
  \new Staff {
	\new Voice = "Sax" {
		\Sax			
	}
  }
  \layout {
  }
}

\score {
    \unfoldRepeats {
        \new Staff {
	      \new Voice = "Sax" {
		      \Sax			
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

