\version "2.18.2"

\header {
    title = "Incondicional"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Pašík & Elinor Kulíšková"
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

attacca = { 
  \once \override Score.RehearsalMark #'break-visibility = #begin-of-line-invisible 
  \once \override Score.RehearsalMark #'direction = #UP
  \once \override Score.RehearsalMark #'font-size = 1 
  \once \override Score.RehearsalMark #'self-alignment-X = #right 
  \mark \markup{\bold Attacca} 
} 

makePercent = #(define-music-function (note) (ly:music?)
   (make-music 'PercentEvent 'length (ly:music-length note)))

Bass = \new Voice \relative c {
    \set Staff.instrumentName = \markup {
        \center-align { "Bass" }
    }

    \clef bass
    \key a \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    
    
    s1*0 ^\markup { "A - Intro" }
    \repeat percent 3 { \makePercent s1 }
    
    s1*0 ^\markup { "Intro (Mexican)" }
    \repeat percent 8 { \makePercent s1 }
    
    
    s1*0 ^\markup { "B - Verse 1" }
    \makePercent s1 | a4 r2. |
    \repeat percent 12 { \makePercent s1 }
    g4. g8 a4. a8 | b4 r2. |
    
    
    s1*0 ^\markup { "C - Chorus" }
    \repeat percent 8 { \makePercent s1 }
    
    s1*0 ^\markup { "D - Guitar Solo 1" }
    \repeat percent 7 { \makePercent s1 }
    r1
    
    s1*0 ^\markup { "E - Verse 2" }
    \makePercent s1 | a4 r2. |
    \repeat percent 12 { \makePercent s1 }
    g4. g8 a4. a8 | b4 r2. |
    
    s1*0 ^\markup { "F - Chorus" }
    \repeat percent 8 { \makePercent s1 }   
    
    s1*0 ^\markup { "G - Brass solo" }
    \repeat percent 8 { \makePercent s1 }   
    
    s1*0 ^\markup { "H - Guitar solo 2" }
    \repeat percent 4 { \makePercent s1 }   
    
    s1*0 ^\markup { "I - Chorus" }
    \repeat percent 8 { \makePercent s1 }  
    
    s1*0 ^\markup { "J - Coda" }
    \repeat percent 3 { \makePercent s1 }  
    
    
    \bar "|."
}

Chords = \chords {
  a1:m | a:m | a:m |
  
  a:m | a:m | g | g |
  d:m | f | c | c | \break
  
  a:m | \set Score.skipBars = ##t R1 | g | g |
  d:m | f | c | c |
  f | f | c | c |
  f | f | g | g |
  
  % Chorus
  \break
  \repeat volta 2 {
    d:m | g | a:m | a:m |
    d:m | f | a:m | a:m 
  }
  
  \break
  d:m | d:m | a:m | a:m |
  d:m | d:m | g | \set Score.skipBars = ##t R1 |
  
  \break
  a:m | \set Score.skipBars = ##t R1 | g | g |
  d:m | f | c | c |
  f | f | c | c |
  f | f | g | g |
  
  % Chorus
  \break
  \repeat volta 2 {
    d:m | g | a:m | a:m |
    d:m | f | a:m | a:m 
  }
  
  \break
  d:m | g | a:m | a:m |
  d:m | f | a:m | a:m |
  
  \repeat volta 2 {
    d2:m g2 | a1:m | d2:m g2 | a1:m |
  }
  
  \break
  d:m | g | a:m | a:m |
  d:m | f | a:m | a:m |
  
  d:m | g | a:m
  
  
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