\version "2.18.2"

\header {
    title = "Star Gees"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Marsik"
    instrument = "trumpet in Bb"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})


Trumpet = \new Voice
\transpose c d
\relative c' {
    \set Staff.instrumentName = \markup {
        \center-align { "Trom. in Bb" }
    }
    \set Staff.midiInstrument = "trumpet"
    \set Staff.midiMaximumVolume = #1.0

    \key g \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        f8 ^\markup { "Intro" } g r ais r4 f ~ |
        f d c8 d f4 |
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
        g1 | \break
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
        g4 r2 r8 a ^\markup { "Panther" } | 
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
        g,4 ^\markup { "007" } bes8 r r4 f' |
        e2 g,2 |
        cis4 d2. ~ |
        d1 |
        g,4 bes8 r r4 f' |
        e2 g,2 |
        d'1 ~ |
        d1 |
        g,4 bes8 r r4 f' |
        e2 d2 |
        g1 |
        g,2 \tuplet 3/2 {bes4 a g}
        d'2 \tuplet 3/2 { r4 bes g }
        d2 d2 | \break
        g2 ^\markup { "Coda" } g |
        g es4. bes'8 |
        g2 es4. bes'8 |
        g2 r |
        d'2 d |
        d es4. bes8 |
        fis2 d4. bes'8 |
        g1 |
        
        
        
        
        
        \break |
    }
    
    
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
	% between-system-space = 10\mm
	between-system-padding = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}