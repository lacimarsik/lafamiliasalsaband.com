\version "2.18.2"

\header {
    title = "Wake Up Song"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Maršík & Elinor Kulíšková"
    instrument = "saxophone in Eb"
    copyright = "© La Familia Salsa Band 2019"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

attacca = { 
  \once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible 
  \once \override Score.RehearsalMark #'direction = #UP
  \once \override Score.RehearsalMark #'font-size = 1 
  \once \override Score.RehearsalMark #'self-alignment-X = #right 
  \mark \markup{\bold Attacca} 
} 

Saxophone = \new Voice \relative c'' {
    \set Staff.instrumentName = \markup {
        \center-align { "Sass. in Eb" }
    }

    \key b \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        fis8 -> -\f ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
        g8 -> -. r r a8 -> -. r r fis4~ ->  |
        fis4. e8 -\mf \< ( ~ e4  f8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Piano Montuno" }
        g8 -\f -> -. r r a8 -> -. r r fis4~ ->  |
    }
    \alternative {
        {
            fis2. r4
        }
        {
            fis4. e8 -\mf \< ( ~ e4  f8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        fis8 -> -\f ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
        g8 -> -. r r a8 -> -. r r fis4~ ->  |
        fis4. e8 -\mf \< ( ~ e4  f8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Coro" }
        g8 -\f -> -. r r a8 -> -. r r fis4~ ->  |
    }
    \alternative {
        {
            fis2. r4
        }
        {
            fis4. e8 -\mf \< ( ~ e4  f8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        fis8 -> -\f ^\markup { "Alarm with ending" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
    }
    \alternative {
        {
            g8 -> -. r r a8 -> -. r r fis4~ -> -\mf \< |
            fis4. e8 ( ~ e4  f8 ) r \!
        }
        {
            g8 -> -. r r a8 -> -. r r fis4 -> -. |
            r8 fis ( e d e d a ais
            \break
        }
    }
    
    b1 \> ) ^\markup { "Clave" } ~ |
    b1 \mp | 
    \set Score.skipBars = ##t R1*2
    R1 ^\markup { "Verse 1" } |
    R1 |
    R1 |
    fis8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 ~ -> \sf \< |
    ais | \break
    
    r2 \! ^\markup { "Pre-Chorus" } b'4 -> \ff r |
    R1 |
    r2 b4 -> r |
    R1 |
    R1 |
    R1 |
    fis8 -> -. \f r r fis -> -. r r fis4 \ff -> |
    R1 | \break
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            d8 -> -. \f r r e -> -. r r fis4 -> -. | \break
        }
    }
    
    \repeat volta 2 {
        \attacca 
        fis8 -> ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
    }
    \alternative {
        {
            g8 -> -. r r a8 -> -. r r fis4~ -> -\mf \< |
            fis4. e8 ( ~ e4  f8 ) r \!
        }
        {
            g8 -> -. r r a8 -> -. r r fis4 -> -. |
            r8 fis ( e d e d a ais
            \break
        }
    }
    
    b1 \> ) ^\markup { "Verse 2" } ~ |
    b1 \mp | 
    R1 |
    fis8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 ~ -> \sf \< |
    ais | \break
    
    r2 \! ^\markup { "Pre-Chorus" } b'4 -> \ff r |
    R1 |
    r2 b4 -> r |
    R1 |
    R1 |
    R1 |
    fis8 -> -. \f r r fis -> -. r r fis4 \ff -> |
    R1 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            d8 -> -. \f r r e -> -. r r fis4 -> -. |
            R1 ^\markup { "Clave" } |
        }
    }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano Montuno" } \break
    
    
    R1 ^\markup { "Flute melody" } |
    R1 |
    R1 |
    fis,8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 ^\markup { "Flute variations" } -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 -> \sf \<  |
    r \f \! ^\markup { "Sax start" } | \break

    \set Score.skipBars = ##t R1*8 ^\markup { "Sax solo (with interruptions)" } | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e'8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            b8 -> -. \f r r cis -> -. r r d4 \fff -! -> |
            R1 | \break
        }
    }
    
    
    \set Score.skipBars = ##t R1* 4 ^\markup { "Pero sí no quieres ..." }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Montuno (Coro Pregón)" } \break
    
    \repeat volta 2 {
      d8 \ff -. ^\markup { "Alarm" } d -. d -. d4 -- cis8 -. cis -. cis -. |
      cis4 -- fis8 -. fis -. fis -. fis -- r fis -- |
      r fis -- r fis -- r4. fis8 -- |
      r fis -- r fis -- r2 | \break
    }
    \set Score.skipBars = ##t R1* 16 ^\markup { "Coro Pregón 2" }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Este dia (sing)" } \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Este dia + Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r d8 -> r | \break
        }
    }
    
    \repeat volta 4 {
        d8 \ff -. ^\markup { "Alarm" } d -. d -. d4 -- cis8 -. cis -. cis -. |
    }
    \alternative {
        {
            cis4 -- fis8 -. fis -. fis -. fis -- r fis -- |
            r fis -- r fis -- r4. gis8 -- |
            r gis -- r gis -- r2 | \break
        }
        {
            cis,4 -- fis8 -. fis -. fis -. fis -. r4 |
            fis8 -. fis -. fis -. fis -. r4 fis8 -. fis -. |
            fis -. fis -.  r4 fis8 -. fis -. fis -. fis -. |
        }
    }
    R1 |
    r2. b,4 |
    
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