\version "2.22.2"

\header {
    title = "Wake Up Song"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Maršík & Elinor Kulíšková"
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2022"
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

Trombone = \new Voice \relative c {
    \set Staff.instrumentName = \markup {
        \center-align { "Trombone" }
    }

    \clef bass
    \key d \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        a'8 -> -\f ^\markup { "Alarm" } a a a -. r2 |
        g8 -> g g g -. r2 |
        bes8 -> -. r r c8 -> -. r r a4~ ->  |
        a4. g8 -\mf \< ( ~ g4  as8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Piano Montuno" }
        bes8 -\f -> -. r r c8 -> -. r r a4~ ->  |
    }
    \alternative {
        {
            a2. r4
        }
        {
            a4. g8 -\mf \< ( ~ g4  as8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        a8 -> -\f ^\markup { "Alarm" } a a a -. r2 |
        g8 -> g g g -. r2 |
        bes8 -> -. r r c8 -> -. r r a4~ ->  |
        a4. g8 -\mf \< ( ~ g4  as8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Coro" }
        bes8 -\f -> -. r r c8 -> -. r r a4~ ->  |
    }
    \alternative {
        {
            a2. r4
        }
        {
            a4. g8 -\mf \< ( ~ g4  as8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        a8 -> -\f ^\markup { "Alarm with ending" } a a a -. r2 |
        g8 -> g g g -. r2 |
    }
    \alternative {
        {
            bes8 -> -. r r c8 -> -. r r a4~ -> -\mf \< |
            a4. g8 ( ~ g4  as8 ) r \!
        }
        {
            bes8 -> -. r r c8 -> -. r r a4 -> -. |
            r8 a ( \ff -> g f g f c cis
            \break
        }
    }
    
    d1 \> ) ^\markup { "Clave" } ~ |
    d1 \mp | 
    \set Score.skipBars = ##t R1*2
    R1 ^\markup { "Verse 1" } |
    R1 |
    R1 |
    a8 -\mp a r c r a ( c ) r |
    d1 -> \< ~ |
    d2. \mf r4 |
    R1 |
    a8 -\mp a r c r a ( c ) r | \break
    d1 -> \mp \< ~ |
    d2. \mf r4 |
    R1 |
    a8 -\mp a r c r a ( c ) r |
    d1 -> \mp \< ~ | 
    d2. \mf r4 |
    a'1 ~ -> \sf \< |
    a | \break
    
    r2 \! ^\markup { "Pre-Chorus" } d4 -> \ff r |
    R1 |
    r2 d4 -> r |
    R1 |
    R1 |
    R1 |
    a8 -> -. \f r r a -> -. r r a4 \ff -> |
    R1 | \break
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            g8 -> -. \f r r g -> -. r r d'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            f,8 -> -. \f r r g -> -. r r a4 -> -. |
        }
    }
    
    \repeat volta 2 {
        \attacca 
        a8 -> ^\markup { "Alarm" } a a a -. r2 |
        g8 -> g g g -. r2 |
    }
    \alternative {
        {
            bes8 -> -. r r c8 -> -. r r a4~ -> -\mf \< |
            a4. g8 ( ~ g4  as8 ) r \!
        }
        {
            bes8 -> -. r r c8 -> -. r r a4 -> -. |
            r8 a ( \ff -> g f g f c cis
            \break
        }
    }
    
    d1 \> ) ^\markup { "Verse 2" } ~ |
    d1 \mp | 
    R1 |
    a8 -\mp a r c r a ( c ) r |
    d1 -> \< ~ |
    d2. \mf r4 |
    R1 |
    a8 -\mp a r c r a ( c ) r | \break
    d1 -> \mp \< ~ |
    d2. \mf r4 |
    R1 |
    a8 -\mp a r c r a ( c ) r |
    d1 -> \mp \< ~ | 
    d2. \mf r4 |
    a'1 ~ -> \sf \< |
    a | \break
    
    r2 \! ^\markup { "Pre-Chorus" } d4 -> \ff r |
    R1 |
    r2 d4 -> r |
    R1 |
    R1 |
    R1 |
    a8 -> -. \f r r a -> -. r r a4 \ff -> |
    R1 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            g8 -> -. \f r r g -> -. r r d'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            f,8 -> -. \f r r g -> -. r r a4 -> -. |
            R1 ^\markup { "Clave" } |
        }
    }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano Montuno" } \break
    
    r4 ^\markup { "Flute melody" } d,8 \f d f ( a -. ) r g -. |
    r f -. r g -. r f -. d4 \tenuto ~ |
    d2 r2 |
    R1 |
    r4 d8 \f d f ( a -. ) r g -. |
    r f -. r g -. r f -. d4 \tenuto ~ |
    d2 r2 |
    R1 | \break
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Flute variations" } \break
    
    r2 \! ^\markup { "Sax solo + Pre-Chorus" } d'4 -> \ff r |
    R1 |
    r2 d4 -> r |
    \set Score.skipBars = ##t R1*5 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            g,8 -> -. \f r r g -> -. r r d'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            f,8 -> -. \f r r a -> -. r r d4 \fff -! -> |
            R1 | \break
        }
    }
    
    \set Score.skipBars = ##t R1* 4 ^\markup { "Pero sí no quieres ..." }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Montuno (Coro Pregón)" } \break
    
    \repeat volta 2 {
      as,8 \ff -. ^\markup { "Alarm" } as -. as -. as4 -- a8 -. a -. a -. |
      a4 -- des8 -. des -. des -. des -- r des -- |
      r des -- r des -- r4. d8 -- |
      r d -- r d -- r2 | \break
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
            g8 -> -. \f r r g -> -. r r d'4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            R1 |
            g,8 -> -. \f r r g -> -. r r as -> r | \break
        }
    }
    
    \repeat volta 4 {
        as,8 \ff -. ^\markup { "Alarm" } as -. as -. as4 -- a8 -. a -. a -. |
    }
    \alternative {
        {
            a4 -- des8 -. des -. des -. des -- r d -- |
            r d -- r d -- r4. d8 -- |
            r d -- r d -- r2 | \break
        }
        {
            a4 -- e'8 -. e -. e -. e -. r4 |
            e8 -. e -. e -. e -. r4 e8 -. e -. |
            e -. e -.  r4 e8 -. e -. e -. e -. |
        }
    }
    R1 |
    r1 \fermata ^\markup { "cue - pianist" } |
    d4 r2. |
    
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

\paper {
	% between-system-space = 10\mm
	between-system-padding = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}