\version "2.18.2"

\header {
    title = "1. Micaela"
    composer = "Pete Rodriguez / Sonora Carruseles"
    arranger = "La Familia Salsa Band"
    instrument = "bass"
    copyright = "© La Familia Salsa Band 2020"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

makePercent =
    #(define-music-function (parser location note) (ly:music?)
       (make-music 'PercentEvent
                   'length (ly:music-length note)))
    
compressPercentRepeat =
#(define-music-function (repeats notes) (integer? ly:music?)
    (let* (
       (mea (ly:music-length notes))
       (num (ly:moment-main-numerator mea))
       (den (ly:moment-main-denominator mea))
       (dur (ly:make-duration 0 0 (* num (1- repeats)) den)))
        #{
            \set Score.restNumberThreshold = #1
            \set Score.skipBars = ##t
            \temporary\override MultiMeasureRest.stencil = #ly:multi-measure-rest::percent
            \temporary\override MultiMeasureRestNumber.stencil =
                  #(lambda (grob)
                       (grob-interpret-markup grob
                         (markup #:concat
                         ( ;; Optional:
                           ;#:fontsize -3 "x"
                           #:fontsize -2 (number->string repeats)))))
            \temporary\override MultiMeasureRest.thickness = #0.48
            \temporary\override MultiMeasureRest.Y-offset = #0
            #(make-music 'MultiMeasureRestMusic 'duration dur)
            \revert MultiMeasureRest.Y-offset
            \revert MultiMeasureRest.thickness
            \revert MultiMeasureRestNumber.stencil
            \revert MultiMeasureRest.stencil
            \unset Score.skipBars
            \unset Score.restNumberThreshold
        #}))

Bass = \new Voice \relative c' {
    \set Staff.instrumentName = \markup {
        \center-align { "Bass" }
    }

    \clef bass
    \key d \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \set Score.skipBars = ##t R1*4 ^\markup { "Hu-Ha" }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano" }

    s1*0 ^\markup { "Percussions" } \repeat percent 4 { \makePercent s1 } \break

    s1*0 ^\markup { "Trumpets" }
    \compressPercentRepeat #4 { \makePercent s1  } |
    
    s1*0 ^\markup { "Coro" }
    \compressPercentRepeat #12 { \makePercent s1  } |
    
    s1*0 ^\markup { "Si senor / Como no" }
    \compressPercentRepeat #8 { \makePercent s1  } |

    s1*0 ^\markup { "Si senor" }
    \makePercent s1 ^\markup { "Si senor" } 
    
    g8 \f \tenuto a \tenuto b \tenuto c \tenuto d4 \tenuto c8 \tenuto \accent c \tenuto \accent \break
    
    s1*0 ^\markup { "Coro" }
    \compressPercentRepeat #12 { \makePercent s1  } |
    
    s1*0 ^\markup { "Si senor / Como no" }
    \compressPercentRepeat #8 { \makePercent s1  } |

    s1*0 ^\markup { "Si senor" }
    \makePercent s1 ^\markup { "Si senor" } 
    
    g,8 \f \tenuto a \tenuto b \tenuto c \tenuto d4 \tenuto c8 \tenuto \accent c \tenuto \accent \break
    
    s1*0 ^\markup { "Coro" }
    \compressPercentRepeat #16 { \makePercent s1  } |

    s1*0 ^\markup { "Piano Solo" }
    \compressPercentRepeat #22 { \makePercent s1  } |

    s1*0 ^\markup { "Piano Solo END" }
    \makePercent s1 |
    \makePercent s1 |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Hu-Ha" }
    
    g16 \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    
    s1*0 ^\markup { "Trumpets 1" }
    \compressPercentRepeat #8 { \makePercent s1  } |
    
    s1*0 ^\markup { "Trumpets 1 END" }
    \makePercent s1 |
    \makePercent s1 |
    
    s1*0 ^\markup { "Ay mira Micaela" }
    \compressPercentRepeat #16 { \makePercent s1  } |
    
    s1*0 ^\markup { "Trumpets 2" }
    \compressPercentRepeat #16 { \makePercent s1  } |
    
    s1*0 ^\markup { "Ay mira Micaela + Trumpet" }
    \compressPercentRepeat #16 { \makePercent s1  } |
    
    s1*0 ^\markup { "Trumpets 3" }
    \compressPercentRepeat #6 { \makePercent s1  } |
    
    \set Score.skipBars = ##t R1*8 ^\markup { "Hu-Ha + Piano change" }
    
    g16 ^\markup { "Trumpets 4" }  \f \accent g8 \accent -. g16 \accent g8 \accent -. r r g \accent g \accent r |
    r g8 \accent -. r4 g8 \accent g8 \accent g8 \accent r |  \break
    
    s1*0 ^\markup { "Montuno" }
    \compressPercentRepeat #8 { \makePercent s1  } |
    
    s1*0 ^\markup { "Trumpets 5" }
    \compressPercentRepeat #6 { \makePercent s1  } |
    c1 |
    
    \bar "|."
}

Chords = \chords {
  \set Score.skipBars = ##t R1*4
  \set Score.skipBars = ##t R1*4
  c2 d | g f |
  c d | g f |
  
}

\score {
  <<
    \Chords
    \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Bass
    }
  >>
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
}
\paper {
    between-system-padding = #2
    bottom-margin = 5\mm
}