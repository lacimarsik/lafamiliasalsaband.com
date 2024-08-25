\version "2.18.2"

\header {
    title = "Oye Como Va"
    composer = "Santana"
    arranger = "Ladislav Maršík"
    instrument = "tenor sax"
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

TenorSax = \new Voice
\transpose c d'
\relative c {
        \set Staff.instrumentName = \markup {
	    \center-align { "T. Sax in Bb" }
	}

        \key a \minor
        \clef treble
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"
	
	\set Score.skipBars = ##t R1*4 ^\markup { "Bass Intro" } |
	
	\set Score.skipBars = ##t R1*4 ^\markup { "Percussions" }
	
	\repeat volta 2 {
	  d'4. \f ^\markup { "Brass" } e8 ( fis g -. ) r fis-.   |
	  r d8 ~ d2 r4 |
	  d4. e8 ( gis g -. ) r fis ~   |
	  fis2.  r4 |
	}
	\repeat volta 2 {
	  d8 r d  e8 ( fis g-. ) r fis-.   |
	  r d8 ~ d2 r4 |
	  d8 r d e ( fis g -. ) r fis ~   |
	  fis2.  r4 |
	}
	
	c4 \f ^\markup { "Break" } c 8 c r c c c |
	r c c c fis c g' r |
	c, r c r c c r fis |
	r c g' r4. g8 r |
	
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*8 ^\markup { "Chorus" }
	}
	
	c,4 \f ^\markup { "Half Break" } c 8 c r c c c |
	r c c c fis c g' r | \break

	\repeat volta 2 {
	  c,8  \tenuto \f ^\markup { "Brass 2" }  c\tenuto  e \tenuto  g \tenuto b \tenuto g \tenuto  b \tenuto a -.  |
	  r fis -.  r2. |
	  c8  \tenuto c\tenuto  e\tenuto  g \tenuto b \tenuto g \tenuto  b \tenuto  a -.  |
	  R1  |
	}
	
	\repeat volta 2 {
	 c,8  \tenuto \f   c\tenuto  e \tenuto  g \tenuto b \tenuto g \tenuto  b \tenuto a -.  |
	  r fis -.  r2. |
	  c8  \tenuto c\tenuto  e\tenuto  g \tenuto b \tenuto g \tenuto  b \tenuto  a -.  |
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
      \TenorSax
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