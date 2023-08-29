\version "2.18.2"

\header {
    title = "Létám"
    composer = "Elinor"
    arranger = "La Familia Salsa Band"
    instrument = "Trumpet"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Trumpet = \new Voice \relative c'' {
    \set Staff.instrumentName = \markup {
        \center-align { "Tr. in Bb" }
    }
    \set Staff.midiInstrument = "trumpet"
    \set Staff.midiMaximumVolume = #1.0

    \key e \minor
    \time 4/4
    \tempo "Andante" 4 = 120


    b4. ^\markup { "Intro" } -\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) |
    b4. -\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) | \break
    r8 g -. g -. g -. g4 -. fis -. |
    
    \repeat volta 2 {
        \set Score.currentBarNumber = 13
        R1 ^\markup { "Verse 1" } |
        R1 |
        g2 -\mp ( a4. fis8 ~ |
        fis2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        g2 ( a4. fis8 ~ |
        fis2. ) r4 |
      }
      {
        g2 ( a4. fis8 ~ |
        fis2 ) r8 d \mf fis g | \break
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
        g2 -\mp ( a4. fis8 ~ |
        fis2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        g2 ( a4. fis8 ~ |
        fis2. ) r4 |
      }
      {
        g2 ( a4. fis8 ~ |
        fis2 ) r8 d \mf fis g | \break
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
            r2 e8 -\f ( g a g | \break
        }
    }
    
    \set Score.currentBarNumber = 50
    b4. ^\markup { "Solo" } e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) |
    
    e4. g4 e8 -. g16 ( a b8 ) |
    b ( d b g a4 b ) |
    e,4. g4 e8 -. g16 ( a b8 ) |
    c -. b4 a16 g b8 -. a4 g8 |
    
    b4. \mordent ( e,8 ~ e8 ) e ( g a |
    c4 a8 b4. a4 ) |
    e4. ( b8 ~ b ) b ( d e ) |
    e ( g fis e d fis e d ) | \break
    
    
    b'4. ^\markup { "Intro" } -\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) |
    b4.-\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) |
    
    r8 g -. g -. g -. g4 -. fis -. |
    
    \repeat volta 2 {
        \set Score.currentBarNumber = 83
        R1 ^\markup { "Verse 3" } |
        R1 |
        g2 -\mp ( a4. fis8 ~ |
        fis2. ) r4 |
        R1 |
        R1 |
        g2 \mp ( a4. fis8 ~ |
        fis2 ) r8 d \mf fis g | \break
    }
    
    r4 ^\markup { "Half Chorus" } a -\mf -\tenuto g -\tenuto d8 d |
    a' ( b g2 ) r4 |
    R1 |
    R1 |
    r4 a -\tenuto g  -\tenuto d8 d |
    a' ( b g2 ) r4 |
    R1 |
    R1 | \break
    
    r2 e8 \mf g ( a g ) |
    d4 -. d2 \tenuto \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2 ^\markup { "Bridge" }
    r2 e8 \mf g ( a g ) |
    d4 -. d2 \tenuto \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 e8 g ( a g ) |
    d4 -. d2 \tenuto \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 e8 g ( a g ) |
    d4 -. d2 \tenuto \sp \< r4 \! |
    \set Score.skipBars = ##t R1*3
    r2 r8 d \mf fis g | \break
    
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
    
    
    b4. ^\markup { "Outro" } -\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 ( a e a d4 a ) |
    b4. -\f ( e,8 ~ e4. ) r8 |
    c'8 ( a e a b4 a ) |
    b4. ( e,8 ~ e4. ) r8 |
    c'8 _\markup { "rit." } ( a e \> a d4 a |
    e1  ) -\mp |
    
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