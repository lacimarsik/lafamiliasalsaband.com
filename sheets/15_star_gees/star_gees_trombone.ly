\version "2.18.2"

\header {
    title = "Star Gees"
    composer = "La Familia Salsa Band"
    arranger = ""
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})


Trumpet = \new Voice \relative c' {
    \set Staff.instrumentName = \markup {
        \center-align { "Trombone" }
    }
    \set Staff.midiInstrument = "trombone"
    \set Staff.midiMaximumVolume = #1.0

    \key g \minor
    \clef bass
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        g1 \p \< ^\markup { "Intro" } ~ |
        g ~ |
        g ~ |
        g2. \f r4 |
        \set Score.skipBars = ##t R1*4 \break
        g1 \p \< ~ |
        g ~ |
        g ~ |
        g2. \f r4 | \break
        
        \set Score.skipBars = ##t R1*8 ^\markup { "Bee Gees" }
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r2 |
        f8 g r g r2 |
        f8 g r g r2 |
        f8 g r g r f r a |
        r g r g r2 |
        \set Score.skipBars = ##t R1*8 \break
        g4 r f r |
        d r c r |
        R1 |
        R1 |
        g'4 r f r |
        d r c r |
        \set Score.skipBars = ##t R1*7 \break
        r2. d4 |
        g1 ^\markup { "Star Wars" } |
        a2. bes8 c |
        bes1 |
        d,2. d4 |
        g2 a |
        bes4 g \tuplet 3/2 {bes g d'}
        g1 |
        r2. d,4 |
        g2. a4 |
        bes g d' bes |
        es1 |
        g,2 \tuplet 3/2 { g4 f es}
        d2 \tuplet 3/2 { r4 d d }
        d2 d2 |
        g1 | \break
        \mark \markup { \musicglyph #"scripts.segno" }
        \set Score.repeatCommands = #'(start-repeat)
        \set Score.skipBars = ##t R1*8 ^\markup { "Bee Gees" }
        d8 e r e r2 |
        d8 e r e r2 |
        d8 e r e r d r f |
        r e r e r2 |
        f8 g r g r2 |
        f8 g r g r2 |
        f8 g r g r f r a |
        r g r g r2 |
        \set Score.skipBars = ##t R1*8 \break
        g4 r f r |
        d r c r |
        R1 |
        R1 |
        g'4 r f r |
        d r c r |
        \set Score.skipBars = ##t R1*7 \break
        r2. d4 |
        g1 ^\markup { "Star Gees" } |
        a2. bes8 c |
        bes1 |
        d,2. d4 |
        g2 a |
        bes4 g \tuplet 3/2 {bes g d'}
        f,8 g r g r2 |
        f8 g r g r2 |
        f8 g r g r f r a |
        r g r g r4 d |
        g2. a4 |
        bes g d' bes |
        es1 |
        g,2 \tuplet 3/2 { g4 f es}
        d2 \tuplet 3/2 { r4 d d }
        d2 ^\markup { \center-column { "To Coda" } } d4. fis,8 | \break
        g4 r2 r8 a ^\markup { "Panther" } | 
        bes4 r2 r8 fis |
        g4 a bes es |
        d g, bes d |
        cis1 \p \< ~ |
        cis1 ~ |
        cis1 \f |
        R1 |
        \set Score.skipBars = ##t R1*2 \break
        g4 r2 r8 a | 
        bes4 r2 r8 fis |
        g4 a bes es |
        d bes d g
        fis1 \p \< ~ |
        fis ~ |
        fis \f |
        r2 r4. fis8 |
        g4 r2 r8 a | 
        bes4 g d' bes |
        es1 |
        g,2 \tuplet 3/2 { g4 f es}
        d2 \tuplet 3/2 { r4 d d }
        d2 d2 |
        g1 |
        R1 | \break
        \set Score.skipBars = ##t R1*6 ^\markup { "Bridge" }
        g1 \p \< ~ |
        g ~ |
        g ~ |
        g2. \f r4 |
        \set Score.skipBars = ##t R1*6 \break
        g1 \p \< ~ |
        g ~ |
        g ~ |
        g2. \f r4 
         g1 \p \< ~ |
        g ~ |
        g ~ |
        g2. \f r4 ^\markup { \center-column { "D.S. al Coda" } } | \break
        \set Score.repeatCommands = #'(end-repeat)
        
        d2 ^\markup { "Coda" } d2 |
        g,2 \ff g |
        g es' |
        g, es' |
        g, r |
        d'2 d |
        d es |
        fis, es |
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