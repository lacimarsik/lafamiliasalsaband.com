\version "2.18.2"

\header {
    title = "13. Oye Como Va"
    composer = "Santana"
    arranger = "Ladislav Maršík"
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

Bass = \new Voice \relative c {
        \set Staff.instrumentName = \markup {
	    \center-align { "Bass" }
	}

        \key a \minor
        \clef bass
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"
	
	a'4 ^\markup { "Bass Intro" } r r8 g r d |
	r4. a'8 d4 c  |
	a4 r r8 g r d |
	r4. a'8 d4 c  |
	
	s1*0 ^\markup { "Percussions" }
	\repeat percent 4 { \makePercent s1 }
	
	s1*0 ^\markup { "Brass" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 }
	}
	
	a,4 ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r4. e8 r |
	
	
	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}
	
	a,4 ^\markup { "Half Break" } a8 a r a a a |
	r a a a d a e' r |

        s1*0 ^\markup { "Brass 2" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 }
	}
	
	a,4 ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r4. e8 r |
	
	
	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}

	d8 ^\markup { "Build up" } d d d d d d d |
	fis fis fis fis fis fis fis fis |
	a a a a a a a a | 
	c c c c c c c c |
	d, d d4 fis8 fis fis4 |
	a8 a a4 \tuplet 3/2 { a a a } |
	
	 s1*0 ^\markup { "Brass 3" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}
	
	a,4 ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r r2 |
	
	s1*0 ^\markup { "Chorus" }
	\repeat volta 2 {
	    \repeat percent 8 { \makePercent s1 } \break
	}
	
	a,4 ^\markup { "Break + Coda" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r r2 |
	
    
    \bar "|."
}

Chords = \chords {
    a1:m | d |
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