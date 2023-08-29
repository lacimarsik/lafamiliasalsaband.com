\version "2.22.2"

\header {
    title = "Micaela"
    composer = "Sonora Carruseles"
    arranger = "La Familia Salsa Band"
    instrument = "trumpet"
    copyright = "© La Familia Salsa Band 2022"
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
        \center-align { "Trumpet" }
    }

    \key c \major
    \clef treble
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Allegro"
    	
    \set Score.skipBars = ##t R1*4 ^\markup { "Hu-Ha" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Percussions" } \break

    r4 a8 ^\markup { "Trumpets" } \p \< a a4 \tenuto a8 \! \mf a |
    g8 -. r g ( bes -. ) r c -. r a \> \accent ~ |
    a8 \mp r r2. |
    R1 |
    r8 a16 \mp a a8 a  \< a4 \tenuto a8 \! \mf a |
    g8 -. r g ( bes -. ) r c -. r a \> \accent ~ |
    a8 \mp r r2. |
    R1 | \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }

    R1 ^\markup { "Si senor" } 
    
    g8 \f \tenuto a \tenuto b \tenuto c \tenuto d4 \tenuto c8 \tenuto \accent c \tenuto \accent \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }
    
    R1 ^\markup { "Si senor" } 
    
    g8 \f \tenuto a \tenuto b \tenuto c \tenuto d4 \tenuto c8 \tenuto \accent c \tenuto \accent \break
    
    \set Score.skipBars = ##t R1*16 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*22 ^\markup { "Piano solo" } \break
    
    \set Score.skipBars = ##t R1*2 ^\markup { "Piano solo END" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Hu-Ha" }
    
    g16 \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    
    \repeat volta 4 {
        es2 ^\markup { "Trumpets 1" } \mp \< ~ es8 ( d -. \mf  ) r c \tenuto |
        r g \< \tenuto c \tenuto d \tenuto es \f \> \tenuto d \tenuto c \tenuto a \mf \tenuto |
    }
        \alternative { 
          {
            r8 g' -. \f a \tenuto ( a \tenuto a \tenuto ) r r g -. |
            a \tenuto ( a \tenuto a \tenuto ) r a \tenuto ( a \tenuto ) r4 |  \break
          }
          {
            r8 ^\markup { "Trumpets 1 END" } g -. \f a \tenuto ( a \tenuto a \tenuto ) r r g -. |
            a \tenuto ( a \tenuto a \tenuto ) r a2 \accent \bendAfter #4  |
          }
        } 
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela" } \break
    
    \repeat volta 2 { r8 ^\markup { "Trumpets 2" } es ( d c ) d4 -. c4 -. |
        c a ~ a r |
        r8 es' ( d c ) d4 -. c4 -. |
        c a ~ a r |
    } \break

    \repeat volta 2 { r8 es'' ( d c ) d4 -. c4 -. |
        c a ~ a r |
    }
    \alternative {
        {
          r8 es' ( d c ) d4 -. c4 -. |
        c a ~ a r |
        }
        {
          r8 es' ( d c ) d4 -. c4 -. |
        c a ~ a2 ~ | 
        }
    }
    a1 |  \break
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela + Trumpet" } \break
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 3" } d, ( e f a4 g8 g |
        g4 -. ) r2. |
    }
    \alternative {
    {    r8 d ( e f a4 g8 g |
    g4 -. ) r2. |
    }
    {    r8 d' ( e f a4 g8 g | \break
    g2 ) \bendAfter #-5 r2 |
    }
    }
    
    \set Score.skipBars = ##t R1*7 ^\markup { "Hu-Ha + Piano change" }
    
    g,16 ^\markup { "Trumpets 4" }  \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    c2 \bendAfter #-5 r2 |
    
    
    \set Score.skipBars = ##t R1*6 ^\markup { "Montuno" }
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 5" } d, ( e f a4 g8 g |
        g4 -. ) r2. |
    }
    \alternative { 
    {
          r8 d ( e f a4 g8 g |
    g4 -. ) r2. |
    }
    {
          r8 d' ( e f a4 g8 g |
    g2 ) \bendAfter #-5 r2 |
    }
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

\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}