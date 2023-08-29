\version "2.18.2"

\header {
    title = "Létám"
    composer = "Elinor"
    arranger = "La Familia Salsa Band"
    instrument = "Trombone"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Trombone = \new Voice \transpose d c \relative c {
    \set Staff.instrumentName = \markup {
        \center-align { "Trombone" }
    }
    \set Staff.midiInstrument = "trombone"
    \set Staff.midiMaximumVolume = #1.0

    \clef bass
    \key e \minor
    \time 4/4
    \tempo "Andante" 4 = 120

    
    \set Score.skipBars = ##t R1*2 ^\markup { "Intro" }

    e4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    r8 b -. b -. b -. b4 -. b, -. |
    
    \repeat volta 2 {
        \set Score.currentBarNumber = 13
        R1 ^\markup { "Verse 1" } |
        R1 |
        a'2 ~ -\mp ( a4. b8 ~ |
        b2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        a2 ~ -\mp ( a4. b8 ~ |
        b2. ) r4 |
      }
      {
        a2 ~ -\mp ( a4. b8 ~ |
        b2 ) r8 fis ( \mf a b ) | \break
      }
    }

    \repeat volta 2 {
        r4 ^\markup { "Chorus" } a -\mf -\tenuto g -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
        R1 |
        r4 a -\tenuto g  -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
        R1 |
    }
    \set Score.skipBars = ##t R1*4 ^\markup { "Bass" } \break
    
    \repeat volta 2 {
        R1 ^\markup { "Verse 2" } |
        R1 |
        a2 ~ -\mp ( a4. b8 ~ |
        b2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        a2 ~ -\mp ( a4. b8 ~ |
        b2. ) r4 |
      }
      {
        a2 ~ -\mp ( a4. b8 ~ |
        b2 ) r8 fis ( \mf a b ) | \break
      }
    }
    
    \repeat volta 2 {
        \set Score.currentBarNumber = 42
        r4 ^\markup { "Chorus" } a -\mf -\tenuto g -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
        R1 |
        r4 a -\tenuto g  -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
    }
    \alternative {
        {
            R1 |
        }
        {
            R1 | \break
        }
    }
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Solo" }
    
    \set Score.skipBars = ##t R1*2 ^\markup { "Intro" }
    e4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    r8 b -. b -. b -. b4 -. b, -. |
    
    \repeat volta 2 {
        R1 ^\markup { "Verse 3" } |
        R1 |
        a'2 ~ -\mp ( a4. b8 ~ |
        b2. ) r4 |
        R1 |
        R1 |
        a2 \mp ~ ( a4. b8 ~ |
        b2 ) r8 fis ( \mf a b ) | \break
    }
    
    r4 ^\markup { "Half Chorus" } a -\mf -\tenuto g -\tenuto d8 d |
    a' ( b g2 ) r4 |
    R1 |
    R1 |
    r4 a -\tenuto g  -\tenuto d8 d |
    a' ( b g2 ) r4 |
    R1 |
    R1 | \break
    
    r2 c,8 \mf e ( fis e ) |
    fis4 -. fis2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2 ^\markup { "Bridge" }
    r2 c8 \mf e ( fis e ) |
    fis4 -. fis2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 c8 \mf e ( fis e ) |
    fis4 -. fis2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 c8 \mf e ( fis e ) |
    fis4 -. fis2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*3
    r2 r8 fis ( \mf a b ) | \break 
    
    \repeat volta 2 {
        r4 ^\markup { "Chorus" } a -\mf -\tenuto g -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
        R1 |
        r4 a -\tenuto g  -\tenuto d8 d |
        a' ( b g2 ) r4 |
        R1 |
        R1 | \break
    }
    
    
    R1 ^\markup { "Outro" } |
    R1 |
    e4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a ( c b d ) |
    e,4. e8 -. g4 \tenuto b \tenuto |
    a _\markup { "rit." } ( c b d |
    e1 ) -\mp |
    
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