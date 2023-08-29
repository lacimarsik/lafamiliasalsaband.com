\version "2.22.2"

\header {
    title = "Micaela"
    composer = "Sonora Carruseles"
    arranger = "La Familia Salsa Band"
    instrument = "sax"
    copyright = "© La Familia Salsa Band 2022"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Sax = \new Voice \transpose c d \relative c'  {
    \set Staff.instrumentName = \markup {
        \center-align { "Sax" }
    }

    \key c \major
    \clef treble
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Allegro"
    	
    \set Score.skipBars = ##t R1*4 ^\markup { "Hu-Ha" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Percussions" } \break

    r4 c8 ^\markup { "Trumpets" } \p \< c c4 \tenuto c8 \! \mf c |
    b8 -. r b ( d -. ) r e -. r c \> \accent ~ |
    c8 \mp r r2. |
    R1 |
    r8 c16 \mp c c8 c  \< c4 \tenuto c8 \! \mf c |
    b8 -. r b ( d -. ) r e -. r c \> \accent ~ |
    c8 \mp r r2. |
    R1 | \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }

    R1 ^\markup { "Si senor" } 
    
    b8 \f \tenuto c \tenuto d \tenuto e \tenuto f4 \tenuto e8 \tenuto \accent e \tenuto \accent \break
    
    \set Score.skipBars = ##t R1*12 ^\markup { "Coro" }
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Si senor / Como no" }
    
    R1 ^\markup { "Si senor" } 
    
    b8 \f \tenuto c \tenuto d \tenuto e \tenuto f4 \tenuto e8 \tenuto \accent e \tenuto \accent \break
    
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
            r8 d -. \f fis \tenuto ( fis \tenuto fis \tenuto ) r r d -. |
            fis \tenuto ( fis \tenuto fis \tenuto ) r fis \tenuto ( fis \tenuto ) r4 |  \break
          }
          {
            r8 ^\markup { "Trumpets 1 END" } d -. \f fis \tenuto ( fis \tenuto f \tenuto ) r r d -. |
            fis \tenuto ( fis \tenuto f \tenuto ) r fis2 \accent \bendAfter #4  |
          }
        } 
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela" } \break
    
    \repeat volta 2 { r8 ^\markup { "Trumpets 2" } bes, ( a g ) a4 -. g4 -. |
        g e ~ e r |
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
    } \break

    \repeat volta 2 { r8 bes'' ( a g ) a4 -. g4 -. |
        g e ~ e r |
    }
    \alternative {
        {
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
        }
        {
        r8 bes' ( a g  ) a4 -. g4 -. |
        g e ~ e r |
        }
    }
    a1 |  \break
    
    \set Score.skipBars = ##t R1*15 ^\markup { "Ay mira Micaela + Trumpet" } \break
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 3" } b, ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    \alternative {
    {    r8 b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    {    r8 b' ( c d f4 e8 e | \break
     e2 ) \bendAfter #-5 r2 |
    }
    }
    
    \set Score.skipBars = ##t R1*7 ^\markup { "Hu-Ha + Piano change" }
    
    g,16 ^\markup { "Trumpets 4" }  \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    c2 \bendAfter #-5 r2 |
    
    
    \set Score.skipBars = ##t R1*6 ^\markup { "Montuno" }
    
    \repeat volta 2 { 
        r8 ^\markup { "Trumpets 5" } b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    \alternative {
    {
          r8 b ( c d f4 e8 e |
        e4 -. ) r2. |
    }
    {
          r8 b ( c d f4 e8 e |
    e2 ) \bendAfter #-5 r2 |
    }
    }
    
    \bar "|."
}

\score {
    \new Staff {
        \new Voice = "Sax" {
            \Sax		
        }
    }
    \layout {
    }
}

\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}