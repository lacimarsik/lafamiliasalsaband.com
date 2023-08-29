\version "2.18.2"

\header {
    title = "Incondicional"
    composer = "Prince Royce"
    arranger = "Ladislav Maršík"
    instrument = "trumpet in Bb"
    copyright = "© La Familia Salsa Band 2019"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Trumpet = \new Voice \transpose c d \relative c'' {
    \set Staff.instrumentName = \markup {
	\center-align { "Trom. in Bb" }
    }

    \key c \major
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \set Score.skipBars = ##t R1*3 ^\markup { "A - Intro Mexican" }
    \set Score.skipBars = ##t R1*6 ^\markup { "Verse 1 Mexican" }
    r2. c8 d |
    \tuplet 3/2 { e4 e e } d 4. c16 d |
    c2. r8 e8 |
    a8 r r2. |\break
    
    \set Score.skipBars = ##t R1*4 ^\markup { "B - Bachata" }
    
    r2 r8 e d c |
    e2. r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    a,4 g8 ( a ) a ( g ) g ( a ) |
    a ( g ) g ( a ) a ( g ) g ( a ) |
    
    \set Score.skipBars = ##t R1*2
    
    \tuplet 3/2 { r4 g' g } \tuplet 3/2 { g g g } |
    g r r2 | \break
    
    r4 ^\markup { "C - Chorus" } f8 e d4 a8 c |
    b2 r2 |
    r4 e8 d e d8 ~ d b |
    c2 r2 |
    
    \set Score.skipBars = ##t R1*2
    
    r4. c16 d e8 -. d -. c -. d -. |
    e16 d e8 ~ e2 r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    r4 e8 d e d8 e d | |
    e2 r2 |
    
    \set Score.skipBars = ##t R1*4 \break
    
    \set Score.skipBars = ##t R1*4 ^\markup { "D - Guitar Solo" } 
    
    r8 f f f r f f r |
    r8 f f f r f f r |
    
    \set Score.skipBars = ##t R1*2 \break
    
    c2. ^\markup { "E - Verse 2" } ~ c8 e |
    a8 r r2. |
    r4 b, \tuplet 3/2 { b b c } |
    d1 |
    r4 c \tuplet 3/2 { a a b } |
    c1 |
    r2 r8 e d c |
    e2. r4 | \break
    
    \set Score.skipBars = ##t R1*2
    a,4 g8 ( a ) a ( g ) g ( a ) |
    a ( g ) g ( a ) a ( g ) g ( a ) |
    
    \set Score.skipBars = ##t R1*2
    
    \tuplet 3/2 { r4 g' g } \tuplet 3/2 { g g g } |
    g r r2 | \break
    
    r4 ^\markup { "C - Chorus" } f8 e d4 a8 c |
    b2 r2 |
    r4 e8 d e d8 ~ d b |
    c2 r2 |
    
    \set Score.skipBars = ##t R1*2
    
    r4. c16 d e8 -. d -. c -. d -. |
    e16 d e8 ~ e2 r4 | \break
    
    \set Score.skipBars = ##t R1*2
    
    r4 e8 d e d8 e d | |
    e2 r2 |
    f8 f r2. |
    a8 a r2. |
    R1 |
    r8 e f e f e f e | \break
    f1 ^\markup { "G - Solo Brass" } |
    r8 d e d e d e d |
    e1 |
    r8 e f e f e f e | \break
    \tuplet 3/2 { f2 e d }
    \tuplet 3/2 { f e d }
    \tuplet 3/2 { c4 c c } \tuplet 3/2 { c c e }
    a4 r2. | \break
    
    \set Score.skipBars = ##t R1*8 ^\markup { "H - Guitar Solo" }
    
    r4 ^\markup { "I - Chorus" } f8 e f e f e |
    f2. r4 |
    r e8 d e d e d |
    e2. r4 |
    f8 f r2. |
    a8 a r2. |
    r4 a,8 ( e ) c' ( a ) e' ( c ) |
    a'8 -. r r2. |
    
    \bar "|."
}

\score {
    \new Staff {
	  \new Voice = "Trumpet" {
		  \Trumpet			
	  }
    }
    \layout {
    }
}

\score {
    \unfoldRepeats {
        \new Staff {
	      \new Voice = "Trumpet" {
		      \Trumpet			
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