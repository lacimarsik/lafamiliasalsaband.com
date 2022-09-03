\version "2.18.2"

\header {
    title = "5. Los Campeones De La Salsa"
    composer = "Luis Enrique"
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

chExceptionMusic = {
  <g b d>1-\markup { \super "7(add9)" }
}

chExceptions = #( append
  ( sequential-music-to-chord-exceptions chExceptionMusic #t)
  ignatzekExceptions)

Bass = \new Voice \relative c, {
        \set Staff.instrumentName = \markup {
	    \center-align { "Bass" }
	}

        \key c \minor
        \clef bass
	\time 4/4
	\tempo 4 = 180
	\tempoMark "Moderato"
	
	\set Score.skipBars = ##t R1*10 ^\markup { "Intro Piano" } \fermataMarkup

	c'4 -> \f ^\markup { "Intro" } r2.  |
        c4 -> r8 c -> r2 |
        as4 -> r2.  |
        as4 -> r8 as -> r2 |
        c4 -> r2 c4  |
        c4 -> r2 c4 |
        g4 -> r2 g4 |
        r8 g' f4 es d | \break

	s1*0 \repeat percent 7 { \makePercent s1 } |
	
	d4. d8 ~ d4 d4 |
	g8 -\f g g g g4 -> r8 d | 
	g4 d8 g ~ g d g4 | \break
	\repeat volta 2 {
	    s1*0 ^\markup { "Chorus" } \repeat percent 7 { \makePercent s1 } |
	}
        \alternative {
          {
            \makePercent s1
          }
          {
            r8 as as g ~ g des4. | \break
          }
        }
        
        c4 ^\markup { "Piano only" } r2. |
        r2 r8 c4 des8 ~ |
        des1 |
        r8 f des as ~ as des4. | \break
	\repeat volta 2 {
	    s1*0 ^\markup { "Verse 1" } \repeat percent 6 { \makePercent s1 } |
	}
        \alternative {
          {
            \makePercent s1
             \makePercent s1
          }
          {
            r8 g -> -. r4 g -> -. r8 g -> -. |
            r4 r8 g -> g4 -> g4 -> -. | \break
          }
        }

	\repeat volta 2 {
	    s1*0 ^\markup { "Chorus" } \repeat percent 7 { \makePercent s1 } |
	}
        \alternative {
          {
            \makePercent s1
          }
          {
            r8 as as g ~ g des4. | \break
          }
        }
        
        c4 ^\markup { "Piano only" } r2. |
        r2 r8 c4 des8 ~ |
        des1 |
        r8 f des as ~ as des4. | \break
	\repeat volta 2 {
	    s1*0 ^\markup { "Verse 2" } \repeat percent 6 { \makePercent s1 } |
	}
	\alternative {
          {
            \makePercent s1
             \makePercent s1
          }
          {
            r8 g -> -. r4 g -> -. r8 g -> -. |
            r4 r8 g -> g4 -> g4 -> -. | \break
          }
        }
	
	c,4 -> \f ^\markup { "Intro" } r2.  |
        c4 -> r8 c -> r2 |
        as4 -> r2.  |
        as4 -> r8 as -> r2 |
        f4 -> r2.  |
        f4 -> r8 f -> r2 |
        d'4 -> r as4 r |
        g4. g g4 |
        s1*0 \repeat percent 6 { \makePercent s1 } |
	g4 -. g -. g -. g -. |
	R1 |
	g4 -. g -. g -. g -. |
	r8 g4 -. as8 -> ~ as4 \bendAfter #-4 r4 | \break
	
        \repeat volta 2 {
	    s1*0 ^\markup { "Ese soy yo" } \repeat percent 8 { \makePercent s1 } | \break
	}
	
	s1*0 ^\markup { "Trumpet Bridge" } \repeat percent 8 { \makePercent s1 } | \break

	\repeat volta 2 {
	  c4 ^\markup { "Reggaeton" } r g r |
	  c r g r |
	  as r es' r |
	  as, r es' es |
	  f, r c' r |
	  f, r c' f, |
	  g r d' r |
	  g r g, r |
	}

	\set Score.skipBars = ##t R1*8 ^\markup { "Bomba - Ese sel mio" }
	s1*0 \repeat percent 8 { \makePercent s1 } | \break

	s1*0 ^\markup { "Chorus" } \repeat percent 8 { \makePercent s1 } | \break
	
	
	
	s1*0 ^\markup { "Solo each instrument" }
        \compressPercentRepeat #96 { \makePercent s1  } |
        
        \set Score.skipBars = ##t R1*8 ^\markup { "On cue - Chorus A Capella" }
        s1*0 ^\markup { "Chorus" } \repeat percent 8 { \makePercent s1 } | \break
        
        \repeat volta 2 { c4 -> \f ^\markup { "Chorus accents" } r2.  |
            c4 -> r8 c -> r2 |
            as4 -> r2.  |
            as4 -> r8 as -> r2 |
            f4 -> r2.  |
            f4 -> r8 f -> r2 |
            d4 -> r as'4 r |
            g4. g g4 | \break
        }
	
	
	c8 \ff ^\markup { "Coda" } c c c es4 -> c -> -. |
	R1 ^\markup { "Conga/Timbal 5 tuplet on 2 bars" } |
	R1 |
	c8 \fff c c c -> -. r2 | 
	
	\bar "||"
}


Chords = \chords {
    \set Score.skipBars = ##t R1*10
    c1:m | c:m | as | as |
    c:m | c:m | g | g |
    c:m | c:m | as | as |
    f:m | f:m | g/d |
    \set majorSevenSymbol = \markup { 7/min9 }
    g:7+/d |
    g | g |
    
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set majorSevenSymbol = \markup { 9/maj11 }
    des:7+ |
    c:m | R1 |
    des:7+ |
    R1 |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set majorSevenSymbol = \markup { 7/sus4 }
    g:7+ |
    \set majorSevenSymbol = \markup { 7/aug5 }
    g:7+ |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set majorSevenSymbol = \markup { 9/maj11 }
    des:7+ |
    c:m | R1 |
    des:7+ |
    R1 |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set majorSevenSymbol = \markup { 7/sus4 }
    g:7+ |
    \set majorSevenSymbol = \markup { 7/aug5 }
    g:7+ |
    c:m | c:m | as | as |
    f:m | f:m |
    \set majorSevenSymbol = \markup { m7/sus5 }
    d:7+ |
    \set majorSevenSymbol = \markup { 7/aug5 }
    g:7+ |
    c:m | c:m | as | as |
    f:m | f:m |
    \set majorSevenSymbol = \markup { sus4 }
    g:7+/d | R1 |
    \set majorSevenSymbol = \markup { 7/aug5 }
    g |
    g:7+ |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    f:m7 | as/es |
    \set majorSevenSymbol = \markup { m7/sus5 }
    d:7+ |
    g |
    f:m7 | as/es |
    \set majorSevenSymbol = \markup { m7/sus5 }
    d:7+ |
    g |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set Score.skipBars = ##t R1*8
    
    c1:m | c:m | as | as |
    f:m | f:m | g | g |
    c:m | c:m | as | as |
    f:m | f:m | g | g |
    \set Score.skipBars = ##t R1*103
    c1:m | c:m | as | as |
    f:m | f:m | g | g |
    c1:m | c:m | as | as |
    f:m | f:m | g | g |
    c:m | R1 | R1 | c:m |
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