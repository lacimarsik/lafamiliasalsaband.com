\version "2.18.2"

\header {
    title = "2. Wake Up Song"
    composer = "La Familia Salsa Band"
    arranger = "Ladislav Maršík & Elinor Kulíšková"
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

Bass = \new Voice \relative c''' {
    \set Staff.instrumentName = \markup {
        \center-align { "Bass" }
    }

    \clef bass
    \key d \minor
    \time 4/4
    \tempo 4 = 180
    \tempoMark "Moderato"
    	
    \repeat volta 2 {
        R1 ^\markup { "Alarm" } |
        R1 |
        R1 |
        R1 | \break
    }
    
    \repeat volta 2 {
        s1*0 ^\markup { "Piano montuno" } \repeat percent 4 { \makePercent s1 } |
    }
    
    \repeat volta 2 {
        a,,8 -> -\f ^\markup { "Alarm" } a a a -. r2 |
        bes,8 -> bes bes bes -. r2 |
        \makePercent s1 |
        \makePercent s1 |
        \break |
    }
    
    \repeat volta 2 {
        s1*0 ^\markup { "Coro" } \repeat percent 4 { \makePercent s1 } |
    }
    
    \repeat volta 2 {
        a'8 -> -\f ^\markup { "Alarm with ending" } a a a -. r2 |
        bes,8 -> bes bes bes -. r2 |
        \makePercent s1 |
        \makePercent s1 | \break
    }
    
    d1 ^\markup { "Clave" } ~ |
    d1 | 
    d'1 ~ |
    d1 | 
    
    \repeat volta 4 {
        s1*0 ^\markup { "Verse 1" } \repeat percent 3 { \makePercent s1 } |
    }
    \alternative {
        {
            a,8 -\mf a r c r a ( c ) r |
        }
        {
            \makePercent s1 | \break
        }
    }
    
    s1*0 ^\markup { "Pre-Chorus" } \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    a8 -> -. \f r r a -> -. r r a4 -> |
    R1 | \break
    
    \repeat volta 2 {
        s1*0 ^\markup { "Chorus" } \repeat percent 6 { \makePercent s1 } |
    }
    \alternative {
        {
            \makePercent s1 |
            \makePercent s1 |
        }
        {
            d8 -> -. \f r r e -> -. r r f4 -> -. | \attacca 
        }
    }
    
    \repeat volta 2 {
        a8 -> -\f ^\markup { "Alarm" } a a a -. r2 |
        bes,8 -> bes bes bes -. r2 |
        \makePercent s1 |
        \makePercent s1 | \break
    }
    
    \repeat volta 4 {
        s1*0 ^\markup { "Verse 2" } \repeat percent 3 { \makePercent s1 } |
    }
    \alternative {
        {
            a8 -\mf a r c r a ( c ) r |
        }
        {
            \makePercent s1 |
        }
    }
    
    s1*0 ^\markup { "Pre-Chorus" } \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    \makePercent s1 |
    a8 -> -. \f r r a -> -. r r a4 -> |
    R1 | \break
    
    \repeat volta 4 {
        s1*0 ^\markup { "Chorus (longer)" } \repeat percent 6 { \makePercent s1 } |
    }
    \alternative {
        {
            \makePercent s1 |
            \makePercent s1 |
        }
        {
            d8 -> -. \f r r e -> -. r r f4 -> -. | 
            R1 ^\markup { "Clave" } |
        }
    }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano Montuno" } \break
    
    s1*0 ^\markup { "Trombone melody" }
    \set Score.repeatCommands = #(list(list 'volta "1.-4.") 'start-repeat)
    \repeat percent 4 { \makePercent s1 } |
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    s1*0 ^\markup { "Sax solo (Pre Chorus)" } \repeat percent 8 { \makePercent s1 } | \break
    
    \repeat volta 4 {
        s1*0 ^\markup { "Chorus (longer)" } \repeat percent 6 { \makePercent s1 } |
    }
    \alternative {
        {
            \makePercent s1 |
            \makePercent s1 |
        }
        {
            d8 -> -. \f r r e -> -. r r f4 -> -. | 
            R1 ^\markup { "Clave" } | \break
        }
    }
    
    \set Score.skipBars = ##t R1* 3 ^\markup { "Pero sí no quieres ..." }
    d4. -> \f g,4. -> bes4 -> |
    
    s1*0 ^\markup { "Montuno (Coro Pregón)" }
    \set Score.repeatCommands = #'((volta "1.-8.") end-repeat)
    { \makePercent s1 | \makePercent s1 | \makePercent s1 | d4. -> \f g,4. -> bes4 -> | }
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    \repeat volta 2 {
      s1*0 ^\markup { "Alarm" }
      { \makePercent s1 | \makePercent s1 | \makePercent s1 | d4. -> \f g,4. -> bes4 -> | } \break
    }
    \repeat volta 4 {
      bes4. \mf ^\markup { "Coro Pregón 2" } c8 r bes r a | \makePercent s1 | \makePercent s1 | | d4. -> \f g,4. -> bes4 -> |
    }
    
    \set Score.repeatCommands = #'((volta "1.-4.") end-repeat)
    bes4. -> \f ^\markup { "Este Dia (sing)" } bes8 -> r2 | R1 |R1 | R1 | \break
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    bes4. -> \ff bes8 -> r2 | R1 | R1 | R1 |
    
    s1*0 ^\markup { "Este Dia + Chorus" }
    \set Score.repeatCommands = #(list(list 'volta "1.-7.") 'start-repeat)
    { \makePercent s1 | \makePercent s1 | \makePercent s1 | \makePercent s1 | } \break
    \set Score.repeatCommands = #'((volta #f) end-repeat)
    
    \repeat volta 4 {
      s1*0 ^\markup { "Alarm" }
      { \makePercent s1 | }
    }
    \alternative {
        {
            \makePercent s1 |
            \makePercent s2 r4. g8 |
            r g r g r2 | 
        }
        {
            r4 ^\markup { "Coda" } a8 -. a -. a -. a -. r4 |
            a8 -. a -. a -. a -. r4 a8 -. a -. |
            a -. a -.  r4 a8 -. a -. a -. a -. |
        }
    }
    R1 |
    r2. d4 |
    
    \bar "|."
}

Chords = \chords {
  R1 | R | R | R |
  a | g | bes | a |
  a | g | bes | a |
  a | g | bes | a |
  a | g | bes | a |
  d:m | d:m | d:m | d:m |
  d:m | d:m | d:m | a:m |
  a:m |
  d:m | a | d:m | a |
  d:m | bes | a | R1 |
  bes:7 | a:7 | d:m7 | g:7 |
  bes:7 | a:7 | d:m7 | g:7 |
  d:m |
  a | g | bes | a |
  d:m | d:m | d:m | a:m |
  a:m |
  d:m | a | d:m | a |
  d:m | bes | a | R1 |
  bes:7 | a:7 | d:m7 | g:7 |
  bes:7 | a:7 | d:m7 | g:7 |
  d:m | R1 |
  R1 | R1 | R1 | R1 |
  d:m | d:m | d:m | a:m |
  d:m | a | d:m | a |
  d:m | bes | a | a |
  bes:7 | a:7 | d:m7 | g:7 |
  bes:7 | a:7 | d:m7 | g:7 |
  d:m | R1 |
  R1 | R1 | R1 | d:m |
  bes:7 | a:7 | cis:dim | d:m |
  bes:7 | a:7 | cis:dim | d:m |
  bes:7 | a:7 | cis:dim | d:m |
  bes | R1 | R1 | R1 |
  bes | R1 | R1 | R1 |
  bes:7 | a:7 | d:m7 | g:7 |
  bes:7 | a:7 | d:m7 | g:7 |
  a | a | a |
  R1 |
  d:m |
  
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