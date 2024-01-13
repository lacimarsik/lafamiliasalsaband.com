\version "2.18.2"

\header {
    title = "Star Gees"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Marsik"
    instrument = "sax"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})


Sax = \new Voice
\transpose c a'
\relative c, {
    \set Staff.instrumentName = \markup {
        \center-align { "Sax" }
    }
    \set Staff.midiInstrument = "trumpet"
    \set Staff.midiMaximumVolume = #1.0

    \key g \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        f8 ^\markup { "Intro" } g r bes r4 f ~ |
        f d c8 d f4 |
        c8 d r f r4 c4 |
        d f g r |
        \set Score.skipBars = ##t R1*4 ^\markup { "Piano" }
                f8  g r ais r4 f ~ |
        f d c8 d f4 |
        c8 d r f r4 c4 |
        d f g r |
        
        \set Score.skipBars = ##t R1*8 ^\markup { "Bee Gees" }
        bes8 c r c r2 |
        bes8 c r c r2 |
        bes8 c r c r bes r d |
        r c r c r2 |
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r2 |
        \set Score.skipBars = ##t R1*8 \break
        d4 r c r |
        bes r a r |
        R1 |
        R1 |
        d4 r c r |
        bes r a r |
        \set Score.skipBars = ##t R1*7 \break
        r2. d,4 |
        g1 ^\markup { "Star Wars" } |
        a2. bes8 c |
        bes1 |
        d,2. d4 |
        g2 a |
        bes4 g \tuplet 3/2 {bes g d'}
        c1 |
        r2. d,4 |
        g2. a4 |
        bes g d' bes |
        g'1 |
        g,2 \tuplet 3/2 {bes4 a g}
        d'2 \tuplet 3/2 { r4 bes g }
        d2 bes'2 |
        g1 |
        R1 |
        \break
        \set Score.skipBars = ##t R1*8 ^\markup { "Bee Gees" }
        bes8 c r c r2 |
        bes8 c r c r2 |
        bes8 c r c r bes r d |
        r c r c r2 |
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r2 |
        \set Score.skipBars = ##t R1*8 \break
        d4 r c r |
        bes r a r |
        R1 |
        R1 |
        d4 r c r |
        bes r a r |
        \set Score.skipBars = ##t R1*7 \break
        r2. d,4 |
        g1 ^\markup { "Star Gees" } |
        a2. bes8 c |
        bes1 |
        d,2. d4 |
        g2 a |
        bes4 g \tuplet 3/2 {bes g d'}
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r4 d,4 |
        g2. a4 |
        bes g d' bes |
        g'1 |
        g,2 \tuplet 3/2 {bes4 a g}
        d'2 \tuplet 3/2 { r4 bes g }
        d2 bes'2 | \break
        g4 ^\markup { "Panther" }  r2 r8 a | 
        bes4 r2 r8 fis |
        g4 a bes es |
        d g, bes d |
        cis1 ~ |
        cis |
        \set Score.skipBars = ##t R1*2 \break
        g4 r2 r8 a | 
        bes4 r2 r8 fis |
        g4 a bes es |
        d bes d g
        fis1 ~ |
        fis |
        \set Score.skipBars = ##t R1*2 \break
        g,4 r2 r8 a | 
        bes4 g d' bes |
        g'1 |
        g,2 \tuplet 3/2 {bes4 a g}
        d'2 \tuplet 3/2 { r4 bes g }
        d2 bes'2 |
        a1 |
        r4. g8 g r g r |
        \break
        R1*6  ^\markup { "Bridge" } 
                f8 ^\markup { "Intro" } g r ais r4 f ~ |
        f d c8 d f4 |
        c8 d r f r4 c4 |
        d f g r |
                R1*6  ^\markup { "Bridge" } 
                f8 ^\markup { "Intro 2x" } g r ais r4 f ~ |
        f d c8 d f4 |
        c8 d r f r4 c4 |
        d f g r |
                        f8 g r ais r4 f ~ |
        f d c8 d f4 |
        c8 d r f r4 c4 |
        d f g r |
        \set Score.skipBars = ##t R1*8 ^\markup { "Bee Gees" }
        bes8 c r c r2 |
        bes8 c r c r2 |
        bes8 c r c r bes r d |
        r c r c r2 |
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r2 |
        \set Score.skipBars = ##t R1*8 \break
        d4 r c r |
        bes r a r |
        R1 |
        R1 |
        d4 r c r |
        bes r a r |
        \set Score.skipBars = ##t R1*7 \break
        r2. d,4 |
        g1 ^\markup { "Star Gees" } |
        a2. bes8 c |
        bes1 |
        d,2. d4 |
        g2 a |
        bes4 g \tuplet 3/2 {bes g d'}
        
        r2 ^\markup { "Break" } r8 c -. r4  |
        r2 r8 c c -. r |
        r2 r4. c8 -. |
        r c -. r c -. r4 d,4 |
        g2. a4 |
        bes g d' bes |
        g'1 |
        g,2 \tuplet 3/2 {bes4 a g}
        d'2 \tuplet 3/2 { r4 bes g }
        d2 bes'2 | \break|
        a1 ~ |
        a1 |
        d1 ~ |
        d1 |
        \set Score.skipBars = ##t R1*7 ^\markup { "Piano Imperial" }
        r4 g,8 bes r c r d \tenuto ~ |
        d4 g, -. r2 |
        \set Score.skipBars = ##t R1*6
        r4 g8 bes r c r d \tenuto ~ |
        d4 g, -. r2 |
        \set Score.skipBars = ##t R1*6
r4 g8 bes r c r d \tenuto ~ |
        d4 g, -. r2 |
        \set Score.skipBars = ##t R1*6
        r4 g8 bes r c r d \tenuto ~ |
        d4 g, -. r2 |
        \set Score.skipBars = ##t R1*6
        r4 ^\markup { "Coda" } g8 bes r c r d \tenuto ~ |
        d4 g -. r2 |
        
        
        
        
        
        \break |
    }
    
    
    \bar "|."
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