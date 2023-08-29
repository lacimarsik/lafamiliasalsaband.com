\version "2.18.2"

\header {
    title = "3. Lonely Boy"
    composer = "Williamsburg Salsa Orchestra"
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

\layout {
  \context {
    \Score
    skipBars = ##t
    autoBeaming = ##f
  }
}

Bass =  \relative c {
    \set Staff.instrumentName = \markup {
	    \center-align { "Bass" }
    }
    
    \key g \minor
    \clef bass
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
	
  
  
      r2. ^\markup { \box { A } } ^\markup { "Piano + Bass" } g4 ~ |
      g4 bes d4. c8 ~ |
      c4. es8 r4 g, ~ |
      g4 bes d4. c8 ~ |
      c4. bes8 r4 g ~ | \break
      
      \repeat volta 2 {
        g4 ^\markup { "Intro 1" } bes d4. c8 ~ |
        c4. es8 r4 g, ~ |
        g4 bes d4. c8 ~ |
        c4. bes8 r4 g -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) | \break
      }
      
      s1*0 ^\markup { "Intro 2" } 
      \repeat volta 2 {
        \repeat percent 2 { \makePercent s1 } 
      }
      \alternative {
        {
          \repeat percent 2 { \makePercent s1 } 
        }
        {   
          r4 f8 f f f f f |
          r f r2. | \break
        }
      }
      
      s1*0 ^\markup { \box { B } } ^\markup { "Verse 1" } 
      \repeat volta 2 {
        \repeat percent 8 { \makePercent s1 } 
      }
      
      d'2 g4 -. f8 d ~ |
      d4. f,8 r f f r | \break
      
       s1*0 ^\markup { \box { C } } ^\markup { "Chorus" } 
      \repeat volta 2 {
        \repeat percent 7 { \makePercent s1 } 
      }
      \alternative {
        {
          \makePercent s1
        }
        {   
           r2. g4 ~ |
        }
      }
      \repeat volta 2 {
        g4 ^\markup { \box { D } } ^\markup { "Intro 2" } bes d4. c8 ~ |
        c4. es8 r4 g, ~ |
        g4 bes d4. c8 ~ |
        c4. bes8 r4 g -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) | \break
      }
      
      s1*0 ^\markup { "Verse 2" } 
      \repeat volta 2 {
        \repeat percent 8 { \makePercent s1 } 
      }
      
      d'2 g4 -. f8 d ~ |
      d4. f,8 r f f r | \break

      s1*0 ^\markup { "Chorus" } 
      \repeat volta 2 {
        \repeat percent 8 { \makePercent s1 } \break
      }
      
      \repeat volta 2 {
          g4. ^\markup { \box { E } } ^\markup { "Bridge" } g8 bes4. g8 ~ |
          g4. f4. fis4 | 
      }
      \alternative {
        {
          g4. g8 bes4. g8 ~ |
          g4. f4. fis4 | 
        }
        {
          g8 [  g8  g8  g8 ] bes4  g8 [  g8 ] |
          r8  d'8 r8  des8 r8  c8 r8  bes8 ~ |
        }
      }
      bes8 ^\markup { "Don't keep me waiting" } [  g8 ] r4 \makePercent s2 |
      \makePercent s1
      \makePercent s1
      \makePercent s1
      
      \set Score.repeatCommands = #(list(list 'volta "1.-3.") 'start-repeat)
          \repeat percent 4 { \makePercent s1 } | \break
      \set Score.repeatCommands = #'((volta #f) end-repeat)
      
      s1*0 ^\markup { "Sax solo" } 
      \repeat volta 2 {
          \repeat percent 4 { \makePercent s1 }
      }
      
      g8 ^\markup { "Build up" }  [ g g g ] g [ g g g ] |
      g8 [ g g g ] g [ g g ] c -> ~ |
      c4. bes4. g4 -\tweak control-points #'((6 . -2.5) (4 . -3) (4 . -3) (1.3 . -2.5)) ( <> ) | \break
      
      s1*0 ^\markup { \box { G } } ^\markup { "Tengo un amor" } 
      \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
      \repeat percent 4 { \makePercent s1 } | \break
      \set Score.repeatCommands = #'((volta #f) end-repeat)
      
      s1*0 ^\markup { "Montuno" } 
      \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
      \repeat percent 4 { \makePercent s1 } | \break
      \set Score.repeatCommands = #'((volta #f) end-repeat)
      
      \repeat percent 2 { \makePercent s1 }
      
      r4  f8 [  f8 ]  f8 [  f8
       f8  f8 ] |
      r8  f8 r4 r2 | \break
      
      s1*0 ^\markup { \box { H } } ^\markup { "Verse 3" } 
      \repeat volta 2 {
        \repeat percent 8 { \makePercent s1 } 
      }
      
      d'2  g8 r8  f8 [  d8 ~ ] | % 148
      d4.  f8 r8  f8 [  f8 ] r8 | % 149
      R1*2 | % 151
      r8 ^\markup { "Coda" }  f8 r8 r8  f8 r8 r8  f8 | % 152
      r4  g8 [  g8 ] r2 \bar "|."
    }
    
    
Chords = \chords {
    g1:m |
    g1:m | c2:m g2:m |
    g1:m | c2:m g2:m |
    g1:m | c2:m g2:m |
    g1:m | c2:m g2:m |
    g1:m | g:m | c | c |
    f | f |
    g:m | g:m | bes | c |
    g:m | g:m | bes | c |
    g:m/d | f |
    g:m | g:m | bes | c |
    g:m | g:m | bes | c |
    c |
    g1:m | c2:m g2:m |
    g1:m | c2:m g2:m |
    g1:m | g:m | bes | c |
    g:m | g:m | bes | c |
    g:m/d | f |
    g:m | g:m | bes | c |
    g:m | g:m | bes | c |
    g:m | g4.:m f4. fis4 |
    g1:m | g4.:m f4. fis4 |
    g1:m | R1 |
    g:m | g:m | bes | c |
    g:m | g:m | bes | c |
    g:m | g:m | bes | c |
    R1*3 |
    g1:m | g:m | bes | c |
    g1:m | g:m | bes | c |
    g1:m | g:m | f | f |
    g1:m | g:m | bes | c |
    g1:m | g:m | bes | c |
    g:m/d | f |
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