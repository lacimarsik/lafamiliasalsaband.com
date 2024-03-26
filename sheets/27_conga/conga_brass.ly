\version "2.18.2"

\header {
    title = "Conga"
    composer = "Gloria Estefan"
    arranger = "Ladislav Maršík"
    instrument = "brass in C"
    copyright = "© La Familia Salsa Band 2016"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \mark \markup { \bold $markp }
#})

Trumpet = \new Voice
%\transpose c d
\relative c'' {
    \set Staff.instrumentName = \markup {
        \center-align { "Trom. in C" }
    }

    \key e \minor
    \time 4/4
    \tempo 4 = 220
    \tempoMark "Allegro"
    
    \partial 1
    d2 \ff -> dis4. -> e8 -. -> |
    
    
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Piano" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Percussions" }
    
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    r1 d2 -> dis4. -> e8 -. -> | \break
    \repeat volta 2 {
        r1 ^\markup { "Brass" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
        r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    }
    r8 e' \tenuto -> \bendAfter #-6 r4 r1. ^\markup { "Verse 1" } |
R1*4
    r2 e,4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e \tenuto -> \bendAfter #-6 | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*3 ^\markup { "Percussions" }
    
    r1 b'8 \ff -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | 
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> | \break
    
    r1 ^\markup { "Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    
    R1*6 ^\markup { "Verse 2" } |
    r2 e4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e -! -^ |
            r1 r2. r8 e -. -> | \break
        }
    }
    \repeat volta 2 {
        r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    }
    \alternative {
        {
            r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
        }
        {
            r1 r2. r8 e' \tenuto -> | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Trumpet solo" }
    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    R\breve | \break
    
    r8 ^\markup { "Brass Bridge" } d, ( \f \< e g a b d e -. -> ) \ff r2 r4 g8 \tenuto g \tenuto |
    g4 \> -> -. fis8 fis \tenuto -. r d -. r a -. \mf r1 |
    r8 e ( \< eis fis ~ \tenuto ) fis a ( b  d ~ \tenuto ) d4 \bendAfter #-2 r8 a ( b \tenuto d dis e \tenuto -. \f ) |
    r2 d4 -. -> e4 -. -> fis4 \tenuto -> ~ fis8 ( d -. ) r2 | \break
    r4. b8 ( \mf \< e -. ->  ) r fis -. -> r g \f -. -> r fis ( e -. -> ) r d -. -> r fis -. -> |
    r d -. -> r4 r8 a -. \mf d -. fis -. \tuplet 3/2 { b4 ( [ \tenuto \ff ais \tenuto a \tenuto \> ] } g8 fis -. \f ) r a -. -> |
    r fis -. -> r d ( fis4 -. -> ) r d8 -. -> r e fis -. -> r d -. -> r e \sff -! -^ |
    r4. e8 -! -^ r4. e8 -! -^ e -! -^ e -! -^ e -! -^ r r4. e'8 \fff \bendAfter #-8 -! -^ | 
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    r1 d,2 \f -> dis4. -> e8 -. -> | \break
    
    \repeat volta 2 {
        r1 ^\markup { "Chorus + Brass variation" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> |
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> | \break
    }

    r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    r8 e' \tenuto -> \bendAfter #-6 r4 r2 r r8 e, -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Outro" } r2 r4 e' -! -^ |

    \bar "|."
}

Saxophone = \new Voice
%\transpose c a
\relative c' {
    \set Staff.instrumentName = \markup {
        \center-align { "Sass. in C" }
    }

    \key e \minor
    \time 4/4
    \tempo 4 = 220
    \tempoMark "Allegro"
    
    \partial 1
    d2 \ff -> dis4. -> e8 -. -> |
    
    
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Piano" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Percussions" }
    
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    r1 d2 -> dis4. -> e8 -. -> | \break
    \repeat volta 2 {
        r1 ^\markup { "Brass" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
        r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    }
    r8 e' \tenuto -> \bendAfter #-6 r4 r1. ^\markup { "Verse 1" } |
R1*4
    r2 e,4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e \tenuto -> \bendAfter #-6 | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*3 ^\markup { "Percussions" }
    
    r1 b'8 \ff -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | 
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> | \break
    
    r1 ^\markup { "Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    
    R1*6 ^\markup { "Verse 2" } |
    r2 e4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
    R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e -! -^ |
            r1 r2. r8 e -. -> | \break
        }
    }
    \repeat volta 2 {
        r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    }
    \alternative {
        {
            r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
        }
        {
            r1 r2. r8 e' \tenuto -> | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Trumpet solo" }
    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    R\breve | \break
    
    r8 ^\markup { "Brass Bridge" } d, ( \f \< e g a b d e -. -> ) \ff r2 r4 b'8 \tenuto b \tenuto |
    b4 \> -> -. a8 a \tenuto -. r fis -. r d -. \mf r1 |
    r8 e, ( \< eis fis ~ \tenuto ) fis a ( b  d ~ \tenuto ) d4 r8 a ( b \tenuto d dis e \tenuto -. \f ) |
    r2 a4 -. -> c4 -. -> d4 \tenuto -> ~ d8 ( a -. ) r2 | \break
    r4. b,8 ( \mf \< e -. ->  ) r fis -. -> r g \f -. -> r fis ( e -. -> ) r d -. -> r fis -. -> |
    r d -. -> r4 r8 a -. \mf d -. fis -. \tuplet 3/2 { g4 ( [ \tenuto \ff fis \tenuto f \tenuto \> ] } e8 d -. \f ) r fis -. -> |
    r d -. -> r b ( d4 -. -> ) r d8 -. -> r e fis -. -> r d -. -> r e \sff -! -^ |
    r4. e8 -! -^ r4. e8 -! -^ e -! -^ e -! -^ e -! -^ r r4. e'8 \fff \bendAfter #-8 -! -^ | 
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    r1 d,2 \f -> dis4. -> e8 -. -> | \break
    
    \repeat volta 2 {
        r1 ^\markup { "Chorus + Brass variation" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> |
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> | \break
    }

    r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    r8 e' \tenuto -> \bendAfter #-6 r4 r2 r r8 e, -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Outro" } r2 r4 e' -! -^ |

    \bar "|."
}

Trombone = \new Voice \relative c, {
    \set Staff.instrumentName = \markup {
        \center-align { "Trombone" }
    }

    \clef bass
    \key e \minor
    \time 4/4
    \tempo 4 = 220
    \tempoMark "Allegro"
    
    \partial 1
    d'2 \ff -> dis4. -> e8 -. -> |
    

    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Piano" }
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Percussions" }
    
    \set Score.skipBars = ##t R\breve*4 ^\markup { "Chorus" }
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    r1 d2 -> dis4. -> e8 -. -> | \break
    \repeat volta 2 {
        r1 ^\markup { "Brass" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
        r1 b'8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    }
    r8 e' \tenuto -> \bendAfter #-6 r4 r1. ^\markup { "Verse 1" } |
R1*4
    r2 e,4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e \tenuto -> \bendAfter #-6 | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*3 ^\markup { "Percussions" }
    
    r1 b'8 \ff -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | 
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e' \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> | \break
    
    r1 ^\markup { "Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |

    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. | \break
    
R1*6  ^\markup { "Verse 2" } |

    r2 e4 \f -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
R1*6 
    r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> | \break
    \repeat volta 2 {
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
    }
    \alternative {
        {
            R\breve |
            r2 e4 -. -> fis -. -> g2 \tenuto -> fis4 . \tenuto -> e8 -. -> |
        } {
            r1 r2. r8 e' -! -^ |
            r1 r2. r8 e -. -> | \break
        }
    }
    \repeat volta 2 {
        r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
        r1 r2 r4. d8 -. -> |
        r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |
    }
    \alternative {
        {
            r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
        }
        {
            r1 r2. r8 e' \tenuto -> | \break
        }
    }
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Trumpet solo" }
    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Chorus + Brass" } r2 r8 e' \f -. -> r d -. -> |
    r1 r2 r8 d -. -> r e -. -> |
    r1 r2 r8 e -. -> r d -. -> |
    R\breve | \break
    
    r8 ^\markup { "Brass Bridge" } d,, ( \f \< e g a b d e -. -> ) \ff r2 r4 g8 \tenuto g \tenuto |
    g4 \> -> -. fis8 fis \tenuto -. r d -. r a -. \mf r1 |
    r8 e ( \< eis fis ~ \tenuto ) fis a ( b  d ~ \tenuto ) d4 r8 a ( b \tenuto d dis e \tenuto -. \f ) |
    r2 d4 -. -> e4 -. -> fis4 \tenuto -> ~ fis8 ( d -. ) r2 | \break
    r4. b8 ( \mf \< e -. ->  ) r fis -. -> r g \f -. -> r fis ( e -. -> ) r d -. -> r fis -. -> |
    r d -. -> r4 r8 a -. \mf d -. fis -. \tuplet 3/2 { g4 ( [ \tenuto \ff fis \tenuto f \tenuto \> ] } e8 d -. \f ) r a' -. -> |
    r d -. -> r b ( d4 -. -> ) r d8 -. -> r e fis -. -> r d -. -> r e \sff -! -^ |
    r4. e8 -! -^ r4. e8 -! -^ e -! -^ e -! -^ e -! -^ r r4. e8 \fff \bendAfter #-8 -! -^ | 
    
    \set Score.skipBars = ##t R\breve*7 ^\markup { "Percussions" }
    
    r1 d2 \f -> dis4. -> e8 -. -> | \break
    
    \repeat volta 2 {
        r1 ^\markup { "Chorus + Brass variation" } r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> |
        r1 r2 r8 e -. -> r d -. -> |
        r1 r2 r4. e8 -. -> | \break
    }

    r1 ^\markup { "Piano + Brass" } r2 r8 e \ff -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |

    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |

    r8 e' \tenuto -> \bendAfter #-6 r4 r2 r r8 e -. -> r d -. -> |
    r1 r2 r4. d8 -. -> |
    r1 d8 -. -> r e fis -. -> r d -. -> r e -. -> |

    r1 b8 -. -> a -. g -. e -. a -. -> g -. e -. e -> -. |
    
    r1 ^\markup { "Outro" } r2 r4 e' -! -^ |

    \bar "|."
}

\score {
    \new StaffGroup <<
        \new Staff << \Trumpet >>
        \new Staff << \Saxophone >>
                \new Staff << \Trombone >>
    >>
    \layout {
    }
}

\score {
    \unfoldRepeats {
        \new StaffGroup <<
            \new Staff << \Trumpet >>
            \new Staff << \Saxophone >>
                            \new Staff << \Trombone >>
        >>
    }
    \midi {
    }
}

\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}