\version "2.22.2"

\header {
		title = "Los Campeones De La Salsa"
		composer = "Willy Chirino"
		arranger = "Ladislav Maršík"
		instrument = "trombone"
		copyright = "© La Familia Salsa Band 2022"
}

tempoMark = #(define-music-function (parser location markp) (string?)
#{
    \once \override Score . RehearsalMark #'self-alignment-X = #left
    \once \override Score . RehearsalMark #'no-spacing-rods = ##t
    \once \override Score . RehearsalMark #'padding = #2.0
    \mark \markup { \bold $markp }
#})

scoopMusic = \relative 
{ 
     \override BendAfter #'rotation = #'(-45 -4 3) 
     \override Score.SpacingSpanner #'shortest-duration-space = #4.0   
}

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

makePercent = #(define-music-function (note) (ly:music?)
   (make-music 'PercentEvent 'length (ly:music-length note)))

Trombone = \new Voice \relative c' {
        \set Staff.instrumentName = \markup {
		\center-align { "Trombone" }
	}

	\key c \minor
        \clef bass
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"


	\set Score.skipBars = ##t R1*4 ^\markup { "Intro Trumpet" }
        c1 ~ |
        c1 |
        d4 -. d -. r8 d4. \tenuto |
        f4 -. f8 f4 -. f8 f f | \break
        
        c4 \bendAfter#-5 r r8 g4 c8 -. |
        r d8 -. r es8 r -. c4. \tenuto |
        r2 r8 g4 c8 -. |
        r d8 -.  r es8 -. r c4. \tenuto  |
        \set Score.skipBars = ##t R1*2
        d8 d d d d4 r |
        R1 |
        d8 d d d d4 r8 c |
        c4 -. c8 b -. r b b4 -. | \break

	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	    g2. ~ g8 g8 ~ -> |
	    g g f g f g16 f es4 -. |
	    es'4 -> r r r8 es8 -. |
	    r4 r8 c d es4. |
	    es4 -. r r2 |
	    r4. c8 d es d es -. |
	    \set Score.skipBars = ##t R1*2
	    g,2. ~ g8 f'8 ~ -> |
	    f f4 -. g -. f4. |
	    es4 -> ^\markup { "Piano Only" } r r2 |
	    r2 r8 g,4 -. f'8 -\sfz -\< ~ |
	    f1 ~ |
	    f1 \ff | \break
	    	    g4 ^\markup { "Verse 1 and 2" } r2. |
	    R1 |
	    r8 as,4. ~ as2 |
	    \set Score.skipBars = ##t R1*11
            r8 g' -> -. r4 g -> -. r8 g -> -. |
            r4 r8 g -> as4 -> g4 -> -. | \break
	}
	
	\set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	    g,2. ~ g8 g8 ~ -> |
	    g g f g f g16 f es4 -. |
	    es'4 -> r r r8 es8 -. |
	    r4 r8 c d es4. |
	    es4 -. r r2 |
	    r4. c8 d es d es -. |
	    \set Score.skipBars = ##t R1*2
	    g,2. ~ g8 f'8 ~ -> |
	    f f4 -. g -. f4. | \break
	    
	c4 ^\markup { "Intro" } r r2 |
	es4. es8 r2 |
	c4  r r2 |
	c4. c8 r2 |
	f4. f8 f4 f8 f ~ |
	f1 |
	r4 d r8 d4. |
	d4. d8 ~ d d d d | \break
	c4 \bendAfter#-5 r r8 g4 c8 ~ |
        c d4 es8 ~ es c4. |
        r2 r8 g4 c8 ~ |
        c d4 es8 ~ es c4. |
        as1 ~ |
        as |
        f'4 f f f |
        r1 |
        f4 f f f |
        r8 f4 f8 \bendAfter#-5 r2 | \break

        \repeat volta 2 {
	    \set Score.skipBars = ##t R1*5 ^\markup { "Ese soy yo" }
        }
        \alternative {
          {
             r8 c f c' c bes4 as8 |
	    g2. ~ g8 es ~ |
	    es es d es d es16 d c4 |
          }
          {
             r8 c f c' c bes4 as8 |
	    g1 |
	    R1 | \break
          }
        }
	
	r4 ^\markup { "Trumpet Bridge" } f r2 |
	r8 as,4 c8 ~ c c c4 |
	c2 c4. b8 ~ |
	b b b b ~ b2 |
	as4 r8 f as as d4 |
	r8 as4 c8 ~ c c c4 |
	f,4 r r r8 d' ~ |
	d d4 d8 ~ d4 g,8 g | \break

        c4 ^\markup { "Reggaeton" } r2. |
	\set Score.skipBars = ##t R1*15 \break

	c,1 \p ^\markup { "Ese sel mio" } ~ |
	c1 |
	as1 ~ |
	as1 |
	g2 f4. as8 ~ |
	as c4. ~ c2 |
	g1 |
	R1 |
	c1 \mf ~ |
	c1 |
	as1 ~ |
	as1 |
	g2 f4. as8 ~ |
	as c4. ~ c2 |
	g1 |
	R1 | \break
	
	\repeat volta 2 {	
	    c1 ^\markup { "Chorus" } ~ |
	    c1 |
	    as1 ~ |
	    as1 |
	    g2 f4. as8 ~ |
	    as c4. ~ c4 b8 c |
	    g1 |
	    R1 | \break
        }
        
        s1*0 ^\markup { "Solo each instrument" }
        \compressPercentRepeat #96 { \makePercent s1  } |
        
        \set Score.skipBars = ##t R1*8 ^\markup { "On cue - Chorus A Capella" }
  
        \set Score.repeatCommands = #(list(list 'volta "1.-3.") 'start-repeat)	
	    c1 ^\markup { "Chorus" } ~ |
	    c1 |
	    as1 ~ |
	    as1 |
	    g2 f4. as8 ~ |
	    as c4. ~ c4 b8 c |
	    g1 |
	    R1 | \break
        \set Score.repeatCommands = #'((volta #f) end-repeat)
	
	
	c8 \ff ^\markup { "Coda" } c c c es4 -> c -> -. |
	R1 ^\markup { "Conga/Timbal 5 tuplet on 2 bars" } | |
	R1 |
	c8 \fff c c c -> -. r2 | 
	
	\bar "||"
}


\score {
  \new Staff {
	\new Voice = "Trombone" {
		\Trombone		
	}
  }
  \layout {
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

