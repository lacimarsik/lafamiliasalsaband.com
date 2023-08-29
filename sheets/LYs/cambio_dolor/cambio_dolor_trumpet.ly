\version "2.18.2"

\header {
    title = "Cambio Dolor"
    composer = "Natalia Oreiro Cover"
    arranger = "Ladislav Maršík"
    instrument = "trumpet in Bb"
    copyright = "© La Familia Salsa Band 2016"
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
		\center-align { "Trom. in Bb" }
	}

    \key e \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    b8 -. \mf r fis' -.  r dis ( e fis g -. ) |
    r b4. -> g8 -. r fis -. r |
    \bar ".|"
    
    e'4 \bendAfter #-8 -> ^\markup{ "Intro" } r4. e,8 -. r g -> ~ |
    g4 e8 -. r r2 |  
    a4 -> r4. e8 -. r a -> ~ |
    a4 e8 -. r r e ( fis g |
    a -. ) a -. r a -. r g -. r fis \tenuto ~ |
    fis4 a8 ( g fis g a b -. ) |
    r g ( a b -. ) r g \< ( a b -. ) |
    r b -. r b -. r dis ( b -. ) r |
    e4 \! \f -> r2. |
    R1 | \break
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Verse 1" }
    r8 b, ( \mp dis e fis4 \tenuto e8 dis |
    e1 \tenuto ) ~ ^\markup{ "Verse 2"} |
    e2 r |
    R1 |
    R1 |
    
    \set Score.skipBars = ##t R1*8
    
    ais,2 \< \tenuto cis \tenuto |
    fis1 -> |
    
    b8 -. \mf r fis -.  r dis ( e fis -. ) r |
    b4. \< \tenuto g \tenuto fis8 -. r | \break 
    
    e' \f -. -> \bendAfter #-8 ^\markup{ "Chorus" } r4. r8 e, \mf -. r g -> ~ |
    g4 e8 -. r r2 |  
    r2 r8 e8 -. r a -> ~ |
    a4 e8 -. r r2 |
    fis8 \sp fis -. r fis -. r2 |
    R1 |
    r8 g \mf ( a b -. ) r g \< ( a b -. ) |
    r b -. r b -. r dis ( b -. ) r | \break

    e \f -. -> \bendAfter #-8 ^\markup{ "Chorus" } r4. r8 e, \mf -. r g -> ~ |
    g4 e8 -. r r2 |  
    r2 r8 e8 -. r a -> ~ |
    a4 e8 -. r r2 |
    fis8 \sp fis -. r fis -. r2 |
    R1 |
    r8 g \mf ( a b -. ) r g \< ( a b -. ) |
    r4. b8 -. r dis -. r b -. | \break
    
    e8 \! \f -. -> r4. r2 |
    R1 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge 1" }
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Verse 3" }
    
    R1 |
    fis,1 \mf \< -> |
    b8 -. -> \f r fis ( a -. ) r fis -. r b -> -. |
    R1 | \break

    \set Score.skipBars = ##t R1*14 ^\markup { "Verse 4 + Flute" }
    
    b8 -. \mf r fis -.  r dis ( e fis -. ) r |
    b4. \< \tenuto g \tenuto fis8 -. r | \break
    
    e' \f -. -> \bendAfter #-8 ^\markup{ "Chorus (brass change)" } r4. r8 a, \mf -. r b -> ~ |
    b4 g8 -. r r2 |  
    r2 r8 b8 -. r c -> ~ |
    c4 a8 -. r r2 |
    fis8 \sp fis -. r fis -. r2 |
    R1 |
    r8 g \mf ( a b -. ) r g \< ( a b -. ) |
    r b -. r b -. r dis ( b -. ) r \! | \break
    
    \repeat volta 3 {
        e \f -. -> \bendAfter #-8 ^\markup{ "3x Chorus (brass change)" } r4. r8 a, \mf -. r b -> ~ |
        b4 g8 -. r r2 |  
        r2 r8 b8 -. r c -> ~ |
        c4 a8 -. r r2 |
        fis8 \sp fis -. r fis -. r2 |
        R1 |
    }
    \alternative {
       {
        r8 g \mf ( a b -. ) r g \< ( a b -. ) |
        r b -. r b -. r dis ( b -. ) r \! | 
       }
       {
        r8 g \mf ( a b -. ) r g \< ( a b -. ) |
        r b -. r b -. r b -. \f r4 | \break
       }
    }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge 2" }
    
    r8 b, \< \mf -. r dis -> ~ dis4 r8 fis -. |
    r a -. r ais ( b \f -. ) r r4 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Saxophone solo" }
    \set Score.skipBars = ##t R1*7 ^\markup { "Verse 5 (half)" }
    
    b4. \mf \< \tenuto g \tenuto fis8 -. r | \break
    
    \repeat volta 4 {
        e' \f -. -> \bendAfter #-8 ^\markup{ "Chorus (original + variation)" } r4. r8 e, \mf -. r g -> ~ |
        g4 e8 -. r r2 |  
        r2 r8 e8 -. r a -> ~ |
        a4 e8 -. r r2 |
        fis8 \mp fis -. r fis -. r  fis ( g a -. ) |
        r4. fis8 \mf -. r g ( a b -. ) |
    }
    \alternative {
      {
        r8 g \mf ( a b -. ) r g \< ( a b -. ) |
        r b -. r b -. r dis ( b -. ) r |
      }
      {
        r8 g \mf ( a b -. ) r g \< ( a b -. ) |
        r4. b8 -. r dis -. r b -. |
      }
    }
    e8 \! \f -. -> r4. r2 |
    
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