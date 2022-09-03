\version "2.18.2"

\header {
    title = "Wake Up Song"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Maršík & Elinor Kulíšková"
    instrument = "brass"
    copyright = "© La Familia Salsa Band 2016"
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
    r2. d4 |
    
    \bar "|."
}

Trumpet = \new Voice \relative c'' {
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
      e8 \ff -. ^\markup { "Alarm" } e -. e -. e4 -- dis8 -. dis -. dis -. |
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
  \new StaffGroup <<
      \new Staff << %{ \global %} \Trumpet >>
      \new Staff << %{ \global %} \Saxophone >>
      \new Staff << %{ \global %} \Trombone >>
  >>
  \layout {
  }
}

\score {
  \unfoldRepeats {
      \new StaffGroup <<
          \new Staff << %{ \global %} \Trumpet >>
          \new Staff << %{ \global %} \Saxophone >>
          \new Staff << %{ \global %} \Trombone >>
      >>
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