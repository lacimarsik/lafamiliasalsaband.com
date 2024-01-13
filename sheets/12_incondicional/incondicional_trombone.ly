\version "2.18.2"

\header {
    title = "Incondicional"
    composer = "Prince Royce"
    arranger = "Ladislav Maršík"
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2019"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Trombone = \new Voice \relative c' {
    \set Staff.instrumentName = \markup {
	\center-align { "Trombone" }
    }

    
    \clef bass
    \key c \major
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \set Score.skipBars = ##t R1*3 ^\markup { "A - Intro Mexican" }
    
    R1 ^\markup { "Verse 1 Mexican" }
    
    r2. a4 ( |
    g2. a4 |
    b1 | \break
    a2. g4 |
    f1 |
    e2. ) a8 b |
    \tuplet 3/2 { c4 c c } b 4. a16 gis |
    a2. r8 c8 |
    e8 r r2. |\break
    
    \set Score.skipBars = ##t R1*4 ^\markup { "B - Bachata" }
    
    r2 r8 c b a |
    c2. r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    f,4 e8 ( f ) f ( e ) e ( f ) |
    f ( e ) e ( f ) f ( e ) e ( f ) |
    
    \set Score.skipBars = ##t R1*2
    
    \tuplet 3/2 { r4 g g } \tuplet 3/2 { a a a } |
    b r r2 | \break
    
    r4 ^\markup { "C - Chorus" } d8 c b4 f8 a |
    g2 r2 |
    r4 c8 b c b8 ~ b g |
    a2 r2 |
    
    \set Score.skipBars = ##t R1*2
    
    r4. a16 b c8 -. b -. a -. b -. |
    c16 b c8 ~ c2 r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    r4 c8 b c b8 c b |
    c2 r2 |
    
    \set Score.skipBars = ##t R1*4 \break
    
    \set Score.skipBars = ##t R1*4 ^\markup { "D - Guitar Solo" } 
    
    r8 d d d r d d r |
    r8 d d d r d d r |
    
    \set Score.skipBars = ##t R1*2 \break
    
    a2. ~ a8 c |
    e8 r r2. |
    r4 g, \tuplet 3/2 { g g a } |
    b1 |
    
    r4 a \tuplet 3/2 { f f g } |
    a1 |
    r2 r8 c b a |
    c2. r4 | \break
    
    \set Score.skipBars = ##t R1*2
    f,4 e8 ( f ) f ( e ) e ( f ) |
    f ( e ) e ( f ) f ( e ) e ( f ) |
    
    \set Score.skipBars = ##t R1*2
    
    \tuplet 3/2 { r4 g g } \tuplet 3/2 { a a a } |
    b r r2 | \break
    
    r4 ^\markup { "C - Chorus" } d8 c b4 f8 a |
    g2 r2 |
    r4 c8 b c b8 ~ b g |
    a2 r2 |
    
    \set Score.skipBars = ##t R1*2
    
    r4. a16 b c8 -. b -. a -. b -. |
    c16 b c8 ~ c2 r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    r4 c8 b c b8 c b |
    c2 r2 |
    d8 d r2. |
    f8 f r2. |
    R1 |
    r8 c d c d c d c | \break
    d1 ^\markup { "G - Solo Brass" } |
    r8 b c b c b c b |
    c1 |
    r8 c d c d c d c | \break
    \tuplet 3/2 { d2 c b }
    \tuplet 3/2 { a g f }
    \tuplet 3/2 { e4 e e } \tuplet 3/2 { e e a }
    c4 r2. | \break
    
    \set Score.skipBars = ##t R1*8 ^\markup { "H - Guitar Solo" }
    
    r4 ^\markup { "I - Chorus" } d8 c d c d c |
    d2. r4 |
    r c8 b c b c b |
    c2. r4 |
    d8 d r2. |
    f8 f r2. |
    r4 e,8 ( c ) a' ( e ) c' ( a ) |
    e'8 -. r r2. |
    
    
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

\score {
    \unfoldRepeats {
        \new Staff {
	      \new Voice = "Trombone" {
		      \Trombone			
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