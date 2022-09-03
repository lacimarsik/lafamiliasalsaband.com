\version "2.18.2"

\header {
    title = "Cambio Dolor"
    composer = "Natalia Oreiro Cover"
    arranger = "Ladislav Maršík"
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2016"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Flute = \new Voice \relative c {
  \set Staff.instrumentName = \markup {
		\center-align { "Trombone" }
	}

    \clef bass
    \key d \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    a8 \mf -. r e' -. r cis ( d e f -. ) |
    r a4. -> f8 -. r e -. r |
    \bar ".|"
    
    f4 -> ^\markup{ "Intro" } r4. f8 -. r f -> ~ |
    f4 f8 -. r r2 |  
    g4 -> r4. g8 -. r g -> ~ |
    g4 g8 -. r r d ( e f |
    g -. ) g -. r g -. r f -. r e \tenuto ~ |
    e4 g8 ( f e f g a -. ) |
    r f ( g a -. ) r f ( \< g a -. ) |
    r a -. r a -. r cis ( a -. ) r |
    a4 \! \f -> r2. |
    R1 | \break

    \set Score.skipBars = ##t R1*16 ^\markup { "Verse 1" }
    \set Score.skipBars = ##t R1*12 ^\markup { "Verse 2" }
    
    R1 |
    e1 \mp \< -> |
    
    a8 -. \mf r e -.  r cis ( d e -. ) r |
    a4. \< \tenuto f \tenuto e8 -. r | \break 
    f \f -. -> \bendAfter #-8 ^\markup{ "Chorus" } r4. r8 f \mf -. r f -> ~ |
    f4 f8 -. r r2 |  
    r2 r8 g8 -. r g -> ~ |
    g4 g8 -. r r2 |
    e8 \sp e -. r e -. r2 |
    R1 |
    r8 f \mf ( g a -. ) r f \< ( g a -. ) |
    r a -. r a -. r cis ( a -. ) r | \break
    a8 \! \f -. -> \bendAfter #-8 ^\markup{ "Chorus" } r4. r8 f \mf -. r f -> ~ |
    f4 f8 -. r r2 |  
    r2 r8 g8 -. r g -> ~ |
    g4 g8 -. r r2 |
    e8 \sp e -. r e -. r2 |
    R1 |
    r8 f \mf ( g a -. ) r f \< ( g a -. ) |
    r4. a8 -. r cis -. r a -. | \break
    a8 \! \f -. -> r4. r2 |
    R1 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge" }
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Verse 3" }
    
    R1 |
    e1 \mf \< -> |
    a8 -. -> \f r e ( g -. ) r e -. r a -> -. |
    r8 a, ( \mp cis d e4 \tenuto d8 cis | \break
    d1 ) ( ^\markup { "Verse 4 + Flute" } |
    d2 ) r2 |
    r2. bes8 ( c | 
    d4 \tenuto c8 bes8 -. ) r g -. r g \tenuto ~ |
    g2 r8 d' -. r c \tenuto ~ |
    c2 r |
    R1 |
    a8 \tenuto ( bes a g -. ) r e -. r f \tenuto ~ |
    f2 ~ f8 ( g a g ~ |
    g2 ) c4. ( \tenuto a8 ) ~ |
    a2 r |
    a4 \tenuto ( c8 f, -. ) r g -. r4 |
    gis2 \tenuto \< ( b2 |
    e2 \tenuto ) \mf r |
    
    a8 -. r e -.  r cis ( d e -. ) r |
    a4. \< \tenuto f \tenuto e8 -. r | \break
    
    f \f -. -> \bendAfter #-8 ^\markup{ "Chorus - brass change" } r r4. e8 \mf -. r f -> ~ |
    f4 d8 -. r r2 |  
    r2 r8 f8 -. r g -> ~ |
    g4 d8 -. r r2 |
    e8 \sp e -. r e -. r2 |
    R1 |
    r8 f \mf ( g a -. ) r f \< ( g a -. ) |
    r a -. r a -. r cis ( a -. ) r \! | \break
    
    \repeat volta 3 {
        a \f -. -> \bendAfter #-8 ^\markup{ "3x Chorus - brass change" } r r4. e8 \mf -. r f -> ~ |
        f4 d8 -. r r2 |  
        r2 r8 f8 -. r g -> ~ |
        g4 d8 -. r r2 |
        e8 \sp e -. r e -. r2 |
        R1 |
    }
    \alternative {
       {
         r8 f \mf ( g a -. ) r f \< ( g a -. ) |
         r a -. r a -. r cis ( a -. ) r \! | 
       }
       {
         r8 f \mf ( g a -. ) r f \< ( g a -. ) |
         r a -. r a -. r a -. \f r4 | \break
       }
    }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge 2" }
    
    r8 a, \< \mf -. r cis -> ~ cis4 r8 e -. |
    r g -. r gis ( a \f -. ) r r4 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Saxophone solo" }
    \set Score.skipBars = ##t R1*7 ^\markup { "Verse 5 (half)" }
    
    a4. \mf \< \tenuto f \tenuto e8 -. r | \break
    
    \repeat volta 4 {
        f \f -. -> \bendAfter #-8 ^\markup{ "Chorus (original + variation)" } r4. r8 f \mf -. r f -> ~ |
        f4 f8 -. r r2 |  
        r2 r8 g8 -. r g -> ~ |
        g4 g8 -. r r2 |
        e8 \mp e -. r e -. r  e ( f g -. ) |
        r4. e8 \mf -. r f ( g a -. ) |
    }
    \alternative {
      {
        r8 f \mf ( g a -. ) r f \< ( g a -. ) |
        r a -. r a -. r cis ( a -. ) r |
      }
      {
        r8 f \mf ( g a -. ) r f \< ( g a -. ) |
        r4. a8 -. r cis -. r a -. |
      }
    }
    a8 \! \f -. -> r4. r2 |
    
    \bar "|."
}

\score {
  \new Staff {
	\new Voice = "Flute" {
		\Flute		
	}
  }
  \layout {
  }
}

\score {
  \unfoldRepeats {
      \new Staff {
	    \new Voice = "Flute" {
		    \Flute			
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