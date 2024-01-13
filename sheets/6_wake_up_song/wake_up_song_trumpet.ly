\version "2.18.2"

\header {
    title = "Wake Up Song"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Maršík & Elinor Kulíšková"
    instrument = "trumpet in Bb"
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

Trumpet = \new Voice \relative c''' {
    \set Staff.instrumentName = \markup {
        \center-align { "Trom. in Bb" }
    }

    \key e \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        b8 -> -\f ^\markup { "Alarm" } b b b -. r2 |
        a8 -> a a a -. r2 |
        c8 -> -. r r d8 -> -. r r b4~ ->  |
        b4. a8 -\mf \< ( ~ a4  bes8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Piano Montuno" }
        c8 -\f -> -. r r d8 -> -. r r b4~ ->  |
    }
    \alternative {
        {
            b2. r4
        }
        {
            b4. a8 -\mf \< ( ~ a4  bes8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        b8 -> -\f ^\markup { "Alarm" } b b b -. r2 |
        a8 -> a a a -. r2 |
        c8 -> -. r r d8 -> -. r r b4~ ->  |
        b4. a8 -\mf \< ( ~ a4  bes8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Coro" }
        c8 -\f -> -. r r d8 -> -. r r b4~ ->  |
    }
    \alternative {
        {
            b2. r4
        }
        {
            b4. a8 -\mf \< ( ~ a4  bes8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        b8 -> -\f ^\markup { "Alarm with ending" } b b b -. r2 |
        a8 -> a a a -. r2 |
    }
    \alternative {
        {
            c8 -> -. r r d8 -> -. r r b4~ -> -\mf \< |
            b4. a8 ( ~ a4  bes8 ) r \!
        }
        {
            c8 -> -. r r d8 -> -. r r b4 -> -. |
            r8 b ( \ff -> a g a g d dis
            \break
        }
    }
    
    e1 \> ) ^\markup { "Clave" } ~ |
    e1 \mp | 
    \set Score.skipBars = ##t R1*2
    R1 ^\markup { "Verse 1" } |
    R1 |
    R1 |
    b8 -\mp b r d r b ( d ) r |
    e1 -> \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r | \break
    e1 -> \mp \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r |
    e1 -> \mp \< ~ | 
    e2. \mf r4 |
    fis1 ~ -> \sf \< |
    fis | \break
    
    r2 \! ^\markup { "Pre-Chorus" } e'4 -> \ff r |
    R1 |
    r2 e4 -> r |
    R1 |
    R1 |
    R1 |
    b8 -> -. \f r r b -> -. r r b4 \ff -> |
    R1 | \break
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            a8 -> -. \f r r a -> -. r r e'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            g,8 -> -. \f r r a -> -. r r b4 -> -. | \break
        }
    }
    
    \repeat volta 2 {
        \attacca 
        b8 -> ^\markup { "Alarm" } b b b -. r2 |
        a8 -> a a a -. r2 |
    }
    \alternative {
        {
            c8 -> -. r r d8 -> -. r r b4~ -> -\mf \< |
            b4. a8 ( ~ a4  bes8 ) r \!
        }
        {
            c8 -> -. r r d8 -> -. r r b4 -> -. |
            r8 b ( \ff -> a g a g d dis
            \break
        }
    }
    
    e1 \> ) ^\markup { "Verse 2" } ~ |
    e1 \mp | 
    R1 |
    b8 -\mp b r d r b ( d ) r |
    e1 -> \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r | \break
    e1 -> \mp \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r |
    e1 -> \mp \< ~ | 
    e2. \mf r4 |
    fis1 ~ -> \sf \< |
    fis | \break
    
    r2 \! ^\markup { "Pre-Chorus" } e'4 -> \ff r |
    R1 |
    r2 e4 -> r |
    R1 |
    R1 |
    R1 |
    b8 -> -. \f r r b -> -. r r b4 \ff -> |
    R1 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            a8 -> -. \f r r a -> -. r r e'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            g,8 -> -. \f r r a -> -. r r b4 -> -. |
            R1 ^\markup { "Clave" } |
        }
    }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano Montuno" } \break
    
    
    R1 ^\markup { "Flute melody" } |
    R1 |
    R1 |
    b,8 -\mp b r d r b ( d ) r |
    e1 -> \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r | \break
    e1 ^\markup { "Flute variations" } -> \mp \< ~ |
    e2. \mf r4 |
    R1 |
    b8 -\mp b r d r b ( d ) r |
    e1 -> \mp \< ~ | 
    e2. \mf r4 |
    fis1 ~ -> \sf \<  |
    fis | \break

    r2 \! ^\markup { "Sax solo + Pre-Chorus" } e'4 -> \ff r |
    R1 |
    r2 e4 -> r |
    \set Score.skipBars = ##t R1*5 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            a,8 -> -. \f r r a -> -. r r e'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            g,8 -> -. \f r r b -> -. r r e4 \fff -! -> |
            R1 | \break
        }
    }
    
    \set Score.skipBars = ##t R1* 4 ^\markup { "Pero sí no quieres ..." }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Montuno (Coro Pregón)" } \break
    
    \repeat volta 2 {
      e,8 \ff -. ^\markup { "Alarm" } e -. e -. e4 -- dis8 -. dis -. dis -. |
      dis4 -- g8 -. g -. g -. g -- r g -- |
      r g -- r g -- r4. g8 -- |
      r g -- r g -- r2 | \break
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
            a,8 -> -. \f r r a -> -. r r e'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            R1 |
            a,8 -> -. \f r r a -> -. r r e' -> r | \break
        }
    }
    
    \repeat volta 4 {
        e8 \ff -. ^\markup { "Alarm" } e -. e -. e4 -- dis8 -. dis -. dis -. |
    }
    \alternative {
        {
            dis4 -- g8 -. g -. g -. g -- r g -- |
            r g -- r g -- r4. a8 -- |
            r a -- r a -- r2 | \break
        }
        {
            dis,4 -- b'8 -. b -. b -. b -. r4 |
            b8 -. b -. b -. b -. r4 b8 -. b -. |
            b -. b -.  r4 b8 -. b -. b -. b -. |
        }
    }
    R1 |
    r2. e,4 |
    
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