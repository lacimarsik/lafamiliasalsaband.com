\version "2.18.2"

\header {
    title = "Would I Lie - Bass"
    composer = "Cubaneros"
    arranger = ""
    instrument = ""
    copyright = "© La Familia Salsa Band 2019"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

Bass = \new Voice \relative c, {
    \set Staff.instrumentName = \markup {
        \center-align { "Bass in C" }
    }

    \key es \major
    \clef bass
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    
    bes4 c d f |
    bes c d g, |
    f a bes b | \break
    c f, fis g |
    d c b g |
    fis f d g' ~ |
    g1 ~ |
    g2 \bendAfter #-5 r2 |
    
    
    \bar "|."
}

\score {
    \new Staff {
        \new Voice = "Bass" {
            \Bass			
        }
    }
    \layout {
    }
}

\score {
    \unfoldRepeats {
        \new Staff {
            \new Voice = "Bass" {
                \Bass
            }
        }
    }
    \midi {
    }
}

\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}