\version "2.18.2"

\header {
    title = "8. Yo No Se Mañana"
    composer = "Luis Enrique"
    arranger = "Ladislav Maršík"
    instrument = "bass"
    copyright = "© La Familia Salsa Band 2018"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
		\once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
		\once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

makePercent = #(define-music-function (note) (ly:music?)
   (make-music 'PercentEvent 'length (ly:music-length note)))

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

Bass = \new Voice \transpose c g \relative c, {
        \set Staff.instrumentName = \markup {
	    \center-align { "Bass" }
	}

        \key bes \major
        \clef bass
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Piano" }
	
	s1*0 ^\markup { "Verse 1" }
	\repeat volta 2 {
	    \repeat percent 4 { \makePercent s1 }
	}
	\alternative {
	  {
	    \repeat percent 4 { \makePercent s1 }
	  }
	  {
	    \repeat percent 4 { \makePercent s1 } \break
	  }
	}
	
	s1*0 ^\markup { "Verse 2" }
	\repeat volta 2 {
	    \repeat percent 4 { \makePercent s1 }
	}
	\alternative {
	  {
	    \repeat percent 4 { \makePercent s1 }
	  }
	  {
	    \repeat percent 3 { \makePercent s1 }
	    f4 _\markup { \italic "cresc." } g bes c | \break
	  }
	}
	
	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}

	s1*0 ^\markup { "Verse 3" }
	\repeat volta 2 {
	    \repeat percent 4 { \makePercent s1 }
	}
	\alternative {
	  {
	    \repeat percent 4 { \makePercent s1 }
	  }
	  {
	    \repeat percent 3 { \makePercent s1 }
	    f,4 _\markup { \italic "cresc." } g bes c | \break
	  }
	}
	
	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}
	
        s1*0 ^\markup { "Bridge 1" }
	\set Score.repeatCommands = #(list(list 'volta "1.-3.") 'start-repeat)
        \repeat percent 8 { \makePercent s1 } \break
        \set Score.repeatCommands = #'((volta #f) end-repeat)

        
        \repeat volta 2 {
            \set Score.skipBars = ##t R1*7
        }
        \alternative {
            {
                R1 |
            }
            {
                f,4 -- -\mf g -- bes -- d -- | \break
            }
        }
        
        s1*0 ^\markup { "Bridge" }
        \repeat volta 4 {
            \makePercent s1
            \makePercent s1
            \makePercent s1
        }
        \alternative {
            {
                f,4 -- g -- bes -- d -- |
            }
            {
                f,4 -\f -- g -- bes -- c -- | \break
            }
        }
        r8 d,4 -> r8 r2 |
        
        s1*0 ^\markup { "Yo no se, Yo no se manana" }
	\repeat percent 7 { \makePercent s1 } \break
        
        \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
        \repeat percent 4 { \makePercent s1 } \break
        \set Score.repeatCommands = #'((volta #f) end-repeat)
        
        	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 }
	}
        
        \set Score.skipBars = ##t R1*2 ^\markup { "Coda" }
        
        es4 \tenuto \f f4 \tenuto  r2 |
    
    \bar "|."
}

Chords = \chords {
    \set Score.skipBars = ##t R1*16
    g1:m | g:m | bes | bes |
    f f | a:m/e | d:m |
    c | c | c | c |
    g1:m | g:m | bes | bes |
    f f | a:m/e | d:m |
    c | c | c | c |
    g1:m | g:m | bes | bes |
    f f | c/e | c |
    g1:m | g:m | bes | bes |
    f f | a:m/e | d:m |
    c | c | c | c |
    g1:m | g:m | bes | bes |
    f f | c/e | c |
    g1:m | g:m | bes | bes |
    f f | c/e | c |
    g1:m | g:m | bes | bes |
    f f | c/e | c |
    c |
    g:m/e | g:dim/a | d:m7 | g |
    g |
    r1 | g:dim/a | d:m7 | g |
    g:m/e | g:dim/a | d:m7 | g |
    g:m/e | g:dim/a | d:m7 | g |
    
    g1:m | g:m | bes | bes |
    f f | c/e | c |
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
	% between-system-space = 10\mm
	between-system-padding = #2
	% system-count = #6
	% ragged-bottom = ##t
	bottom-margin = 5\mm
	% top-margin = 0\mm
	% paper-height = 310\mm
}