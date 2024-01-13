\version "2.18.2"

\header {
    title = "Incondicional"
    composer = "Prince Royce"
    arranger = "Ladislav Maršík"
    instrument = "saxophone"
    copyright = "© La Familia Salsa Band 2019"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Saxophone = \new Voice \transpose es c \relative c' {
    \set Staff.instrumentName = \markup {
	\center-align { "Saxophone" }
    }

    \clef treble
    \key c \major
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \set Score.skipBars = ##t R1*3 ^\markup { "Intro Mexican" }
    
    R1 ^\markup { "Verse 1 Mexican" }
    
    r2. c4 |
    b2. c4 |
    d1 | \break
    c2. b4 |
    a1 |
    g2. r4 |
    R1 |
    a1 |
    R1 | \break
    
    \set Score.skipBars = ##t R1*5 ^\markup { "B - Bachata" } 
    c16 b c d
    e d e f g f g a b c d e |
    f1 ( |
    c1 ) |
    
    \set Score.skipBars = ##t R1*4
    
    \tuplet 3/2 { r4 g g } \tuplet 3/2 { a a a } |
    b r r2 | \break
    
    \set Score.skipBars = ##t R1*3 ^\markup { "C - Chorus" }
    
    r2. g16 ( a b c |
    d1 |
    f2 d2 |
    c1 ~ |
    c2 ) r2 |  \break
    r4 d,8 ( e f g a d |
    b4 g2. ) |
    
    \set Score.skipBars = ##t R1*4
    
    c1 |
    
    R1 | \break

    \set Score.skipBars = ##t R1*8 ^\markup { "D - Solo Guitar" } \break
    
    \set Score.skipBars = ##t R1*3 ^\markup { "E - Verse 2" }
    
    d,1 \tenuto |
    d1 \tenuto |
    c2 ( f2 |
    e1 ) |
    c16 b c d
    e d e f g f g a b c d e | \break

    f1 ( |
    c1 ) |
    
    \set Score.skipBars = ##t R1*4
    
    \tuplet 3/2 { r4 g g } \tuplet 3/2 { a a a } |
    b r r2 | \break
    
    \set Score.skipBars = ##t R1*3 ^\markup { "F - Chorus" }
    
    r2. g16 ( a b c |
    d1 |
    f2 d2 |
    c1 ~ |
    c2 ) r2 |  \break
    r4 d,8 ( e f g a d |
    b4 g2. ) |
    
    \set Score.skipBars = ##t R1*4
    
    e'1 |
    
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