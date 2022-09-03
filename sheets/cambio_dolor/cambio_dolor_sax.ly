\version "2.18.2"

\header {
    title = "Cambio Dolor"
    composer = "Natalia Oreiro cover"
    arranger = "Ladislav Maršík"
    instrument = "alto saxophone in Eb"
    copyright = "© La Familia Salsa Band 2016"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Saxophone = \new Voice \relative c' {
  \set Staff.instrumentName = \markup {
		\center-align { "Sass. in Eb" }
	}
    \key b \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"	
      	
    fis8 \mf -. r cis' -. r ais ( b cis d -. ) |
    r fis4. -> d8 -. r cis -. r |
    \bar ".|"
    
    b4 -> ^\markup{ "Intro" } r4. b8 -. r b -> ~ |
    b4 b8 -. r r2 |  
    b4 -> r4. b8 -. r b -> ~ |
    b4 b8 -. r r b ( cis d |
    e -. ) e -. r e -. r d -. r cis \tenuto ~ |
    cis4 e8 ( d cis d e fis -. ) |
    r d ( e fis -. ) r d ( \< e fis -. ) |
    r fis -. r fis -. r ais ( fis -. ) r |
    d4 \! \f -> r2. |
    R1 | \break
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Verse 1" }
    r8 fis, ( \mp ais b cis4 \tenuto b8 ais |
    b1 \tenuto ) ~ ^\markup{ "Verse 2" } |
    b2 r |
    R1 |
    R1 |
    
    \set Score.skipBars = ##t R1*8
    
    eis,2 \< \tenuto gis \tenuto |
    cis1 -> |
    
    fis8 -. \mf r cis -.  r ais ( b cis -. ) r |
    fis4. \< \tenuto d \tenuto cis8 -. r | \break
    
    b \f -. -> ^\markup{ "Chorus" } r4. r8 b \mf -. r b -> ~ |
    b4 b8 -. r r2 |  
    r2 r8 b8 -. r b -> ~ |
    b4 b8 -. r r2 |
    a8 \sp a -. r a -. r2 |
    R1 |
    r8 d \mf ( e fis -. ) r d \< ( e fis -. ) |
    r fis -. r fis -. r ais ( fis -. ) r | \break
    
    d8 \! \f -> ^\markup{ "Chorus" } r4. r8 b \mf -. r b -> ~ |
    b4 b8 -. r r2 |  
    r2 r8 b8 -. r b -> ~ |
    b4 b8 -. r r2 |
    a8 \sp a -. r a -. r2 |
    R1 |
    r8 d \mf ( e fis -. ) r d \< ( e fis -. ) |
    r4 r8 fis -. r ais -. r fis -. | \break
    d8 \! \f -> r4. r2 |
    R1 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge" }
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Verse 3" }
    
    R1 |
    cis1 \mf \< -> |
    fis8 -. -> \f r cis ( e -. ) r cis -. r fis -> -. |
    R1 |
    
    \set Score.skipBars = ##t R1*14 ^\markup { "Verse 4 + Flute" }
     
    fis8 -. \mf r cis -.  r ais ( b cis -. ) r |
    fis4. \< \tenuto d \tenuto cis8 -. r | \break
    
    b \f -. -> \bendAfter #-8 ^\markup{ "Chorus (brass change)" } r4. r8 a \mf -. r b -> ~ |
    b4 b8 -. r r2 |  
    r2 r8 b8 -. r b -> ~ |
    b4 b8 -. r r2 |
    a8 \sp a -. r a -. r2 |
    R1 |
    r8 d \mf ( e fis -. ) r d \< ( e fis -. ) |
    r fis -. r fis -. r ais ( fis -. ) r \! | \break
    
    \repeat volta 3 {
        d \f -. -> \bendAfter #-8 ^\markup{ "3x Chorus (brass change)" } r4. r8 a \mf -. r b -> ~ |
        b4 b8 -. r r2 |  
        r2 r8 b8 -. r b -> ~ |
        b4 b8 -. r r2 |
        a8 \sp a -. r a -. r2 |
        R1 |
    }
    \alternative {
       {
        r8 d \mf ( e fis -. ) r d \< ( e fis -. ) |
        r fis -. r fis -. r ais ( fis -. ) r \! | 
       }
       {
        r8 d \mf ( e fis -. ) r d \< ( e fis -. ) |
        r fis -. r fis -. r fis -. \f r4 | \break
       }
    }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Bridge 2" }
    
    r8 fis, \< \mf -. r ais -> ~ ais4 r8 cis -. |
    r e -. r eis ( fis \f -. ) r r4 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Saxophone solo" }
    \set Score.skipBars = ##t R1*7 ^\markup { "Verse 5 (half)" }
    
    fis4. \mf \< \tenuto d \tenuto cis8 -. r | \break
    
    \repeat volta 4 {
        b \f -. -> \bendAfter #-8 ^\markup{ "Chorus (original + variation)" } r4. r8 b \mf -. r b -> ~ |
        b4 b8 -. r r2 |  
        r2 r8 b8 -. r b -> ~ |
        b4 b8 -. r r2 |
        a8 \mp a -. r a -. r  a ( b cis -. ) |
        r4. cis8 \mf -. r d ( e fis -. ) |
    }
    \alternative {
      {
        r8 d ( e fis -. ) r d \< ( e fis -. ) |
        r fis -. r fis -. r ais ( fis -. ) r \! |
      }
      {
        r8 d ( e fis -. ) r d \< ( e fis -. ) |
        r4. fis8 -. r ais -. r fis -. |
      }
    }
    d8 \! \f -. -> r4. r2 |
    
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
	% between-system-space = 10\mm
	between-system-padding = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}