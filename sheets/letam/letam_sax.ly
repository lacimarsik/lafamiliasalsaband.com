\version "2.18.2"

\header {
    title = "Létám"
    composer = "Elinor"
    arranger = "La Familia Salsa Band"
    instrument = "Saxophone"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Saxophone = \new Voice \transpose es bes \relative c' {
    \set Staff.instrumentName = \markup {
	\center-align { "Sax in Eb" }
    }
    \set Staff.midiInstrument = "alto sax"
    \set Staff.midiMaximumVolume = #1.0

    \key e \minor
    \time 4/4
    \tempo "Andante" 4 = 120

    
    \set Score.skipBars = ##t R1*4 ^\markup { "Intro" }

    e4. ( \mp e4 b8 e g |
    c,4 e d fis ) |
    e4. ( e4 b8 e g |
    c,4 e d fis ) |
    r8 e -. e -. e -. e4 -. d -. |
    
    \repeat volta 2 {
        R1 ^\markup { "Verse 1" } |
        R1 |
        e2 -\mp ( fis4. d8 ~ |
        d2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        e2 -\mp ( fis4. d8 ~ |
        d2. ) r4 |
      } {
        e2 -\mp ( fis4. d8 ~ |
        d2 ) r8 b \mf [ d e ] | \break 
      }
    }

    \repeat volta 2 {
        r4 ^\markup { "Chorus" } fis -\mf -\tenuto e -\tenuto b8 b |
        fis' ( g e2 ) r4 |
        R1 |
        R1 |
        r4 fis -\tenuto e  -\tenuto b8 b |
        fis' ( g e2 ) r4 |
        R1 |
        R1 |
    }
    \set Score.skipBars = ##t R1*4 ^\markup { "Bass" } \break
    
    \repeat volta 2 {
        R1 ^\markup { "Verse 2" } |
        R1 |
        e2 -\mp ( fis4. d8 ~ |
        d2. ) r4 |
        R1 |
        R1 |
    }
    \alternative {
      {
        e2 -\mp ( fis4. d8 ~ |
        d2. ) r4 |
      } {
        e2 -\mp ( fis4. d8 ~ |
        d2 ) r8 b \mf [ d e ] | \break 
      }
    }
    
    \repeat volta 2 {
        r4 ^\markup { "Chorus" } fis -\mf -\tenuto e -\tenuto b8 b |
        fis' ( g e2 ) r4 |
        R1 |
        R1 |
        r4 fis -\tenuto e  -\tenuto b8 b |
        fis' ( g e2 ) r4 |
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

    \set Score.skipBars = ##t R1*4 ^\markup { "Intro" }
    e4. ( \mp e4 b8 e g |
    c,4 e d fis ) |
    e4. ( e4 b8 e g |
    c,4 e d fis ) |
    r8 e -. e -. e -. e4 -. d -. |
    
    \repeat volta 2 {
        R1 ^\markup { "Verse 3" } |
        R1 |
        e2 -\mp ( fis4. d8 ~ |
        d2. ) r4 |
        R1 |
        R1 |
        e2 \mp ( fis4. d8 ~ |
        d2 ) r8 b \mf [ d e ] | \break 
    }
    
    r4 ^\markup { "Half Chorus" } fis -\mf -\tenuto e -\tenuto b8 b |
    fis' ( g e2 ) r4 |
    R1 |
    R1 |
    r4 fis -\tenuto e  -\tenuto b8 b |
    fis' ( g e2 ) r4 |
    R1 |
    R1 | \break
    
    
    r2 e8 \mf g ( a g ) |
    b4 -. b2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2 ^\markup { "Bridge" }
    r2 e,8 \mf g ( a g ) |
    b4 -. b2 \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 e,8 \mf  g ( a g ) |
    b4 -. b2 \tenuto \sp \< r4 \! |
    \set Score.skipBars = ##t R1*2
    r2 e,8 \mf  g ( a g ) |
    b4 -. b2 \tenuto r4 |
    \set Score.skipBars = ##t R1*3
    r2 r8 b, \mf [ d e ] | \break 
    
    \repeat volta 2 {
        r4 ^\markup { "Chorus" } fis -\mf -\tenuto e -\tenuto b8 b |
        fis' ( g e2 ) r4 |
        R1 |
        R1 |
        r4 fis -\tenuto e  -\tenuto b8 b |
        fis' ( g e2 ) r4 |
        R1 |
        R1 | \break
    }
    
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Outro" }
    e4. ( \mp e4 b8 e g |
    c,4 e d fis ) |
    e4. ( e4 b8 e g |
    c,4 _\markup { "rit." } e \> d fis |
    e1 ) \p |
    
     
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