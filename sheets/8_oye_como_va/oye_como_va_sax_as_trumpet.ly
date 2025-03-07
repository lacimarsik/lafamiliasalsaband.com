\version "2.18.2"

\header {
    title = "Oye Como Va"
    composer = "Santana"
    arranger = "Ladislav Maršík"
    instrument = "sax as trumpet"
    copyright = "© La Familia Salsa Band 2022"
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

Trumpet = \new Voice
\transpose c a,
\relative c'' {
        \set Staff.instrumentName = \markup {
	    \center-align { "Sax as tr." }
	}

        \key a \minor
        \clef treble
	\time 4/4
	\tempo 4 = 150
	\tempoMark "Moderato"
	
	\set Score.skipBars = ##t R1*4 ^\markup { "Bass Intro" } |
	
	\set Score.skipBars = ##t R1*4 ^\markup { "Percussions" }
	
	\repeat volta 2 {
	  a4. \f ^\markup { "Brass" } b8 ( c d -. ) r b-.   |
	  r a8 ~ a2 r4 |
	  a4. b8 ( c d -. ) r b ~   |
	  b2.  r4 |
	}
	\repeat volta 2 {
	  a8 r a  b8 ( c d -. ) r b-.   |
	  r a8 ~ a2 r4 |
	  a8 r a b ( c d -. ) r b ~   |
	  b2.  r4 |
	}
	
	a4 \f ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r4. e8 r |
	
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*8 ^\markup { "Chorus" }
	}
	
	a,4 \f ^\markup { "Half Break" } a8 a r a a a |
	r a a a d a e' r | \break

	\repeat volta 2 {
	  a,8  \tenuto \f ^\markup { "Brass 2" }  a\tenuto  c \tenuto  e \tenuto g \tenuto e \tenuto  g \tenuto  fis -.  |
	  r d -.  r2. |
	  a8  \tenuto  a\tenuto  c \tenuto  e \tenuto g \tenuto e \tenuto  g \tenuto  fis -.  |
	  R1  |
	}
	
	\repeat volta 2 {
	  a,8  \tenuto \f a\tenuto  c \tenuto  e \tenuto g \tenuto e \tenuto  g \tenuto  fis -.  |
	  r d -.  r2. |
	  a8  \tenuto  a\tenuto  c \tenuto  e \tenuto g \tenuto e \tenuto  g \tenuto  fis -.  |
	  R1  | \break
	}
	
	a,4 \f ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r4. e8 r |
	
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*8 ^\markup { "Chorus" }
	}

	d8 ^\markup { "Build up" } d d d d d d d |
	fis fis fis fis fis fis fis fis |
	a a a a a a a a | 
	c c c c c c c c |
	d, d d4 fis8 fis fis4 |
	a8 a a4 \tuplet 3/2 { a a a } |
	
		\repeat volta 2 {
	    \set Score.skipBars = ##t R1*16 ^\markup { "Brass solos" }
	}
	
	
	a,4 ^\markup { "Break" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r r2 |
	
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*8 ^\markup { "Chorus" }
	}
	
	
	\repeat volta 2 {
	  c'8  \tenuto \f ^\markup { "Brass 3" }  c \tenuto  g -.  r c \tenuto g -.  r  c -.  |
	  r fis, -.  r4 c'8 c fis, r |
	  c'  \tenuto \f ^\markup { "Brass 3" }  c \tenuto  g -.  r c \tenuto g -.  r  c -.  |
	  r fis, -.  r4 c'8 c fis, r |
	}
	
	
	a,4 ^\markup { "Break + Coda" } a8 a r a a a |
	r a a a d a e' r |
	a, r a r a a r d |
	r a e' r r2 |
	
    
    \bar "|."
}

\score {
  <<
    \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Trumpet
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