\version "2.19.83"

\header {
    title = "Sera Que No Me Amas"
    composer = "Tony Succar"
    arranger = "Ladislav Maršík"
    instrument = "bone"
    copyright = "© La Familia Salsa Band 2022"
}

Trombone = \new Voice \relative c'{
    \set Staff.instrumentName = \markup {
      \center-align { "Bone" }
    }
    
    \set Staff.midiInstrument = "trombone"
    \set Staff.midiMaximumVolume = #1.0

    \clef bass
    \key a \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    
       \set Score.skipBars = ##t R1*8
       \set Score.skipBars = ##t R1*2
       r4 a4 -. \mf r2 |
       R1 | \break
       r4. c8 -. \accent \f r2 |
       r4. c,8 ~ c4 \bendAfter #-4  \mf \accent r4 |
       r8 c8  \tenuto g \tenuto gis \tenuto  a \tenuto c \tenuto a \tenuto f' -. \accent  |

       r2 r8 b,8 \f  \tenuto ~ b4 | \break
      \mark \markup { \musicglyph "scripts.segno" }
       a4 ^\markup { "Verse, Sax C" } \accent  \bendAfter #-4  r2. | 
      \set Score.skipBars = ##t R1*2
      r8 c'8 -. \accent \f r2. |
     \set Score.skipBars = ##t R1*2
     f,2 \mf r4 e \accent ~ |
     e8 e \tenuto \f r g \tenuto r e ( d )  r | \break
     R1 |
     r8 a' ( g e g a -. ) r4  |
     r2 e4 \f \tenuto e -. |
     e4 \tenuto ( e8 g e4 -.  \tenuto ) r | 
     r4. f8 -. \accent \f r2 |
     r4. c8 -. \accent ~ c8 \bendAfter #-4 r4. |
     r4. g'8 ( g e g g -. ) |
     r8  g, -. r2. | \break
     r2 ^\markup { "Chorus " }  r8 g' a -. r | 
     c \f \tenuto \accent c \tenuto \accent r2. |
     r4. \mf es,8 r f r bes | 
     r g8 ~ g r8 f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" }  -. \accent \f r |
     r8 f8 -. \accent r2. |
     r4. g8 \mf r a ~ a4 |
     r8 g a -. r g a \tenuto ~ a r | \break
     r2r8 g a r | 
     r c \tenuto \accent ~ c4 r2 |
     r4. es,8 r f r bes | 
     r g ~ g r f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" } -. \accent \f r |
     r8 f8 -. \accent r2. |
    r8 g8 \mf  \tenuto d \tenuto dis \tenuto  e \tenuto g \tenuto e \tenuto a -. \accent  |
    R1 | \break
     a2^\markup { "Verse, Sax C" } \accent  \bendAfter #-4  r2 | 
      \set Score.skipBars = ##t R1*2
      r8 c8 -. \accent \f r2. |
     \set Score.skipBars = ##t R1*2
     f,2 \mf r4 e \accent ~ |
     e8 e \tenuto \f r g \tenuto r e ( d )  r | \break
     R1 |
     r8 a' ( g e g a -. ) r4  |
     r2 e4 \f \tenuto e -. |
     e4 \tenuto ( e8 g e4 -.  \tenuto ) r | 
     r4. f8 -. \accent \f r2 |
     r4. c8 -. \accent ~ c8 \bendAfter #-4 r4. |
     r4. g'8 ( g e g g -. ) |
     r8  g, -. r2. | \break
     r2 ^\markup { "Chorus " }  r8 g' a -. r | 
     c \f \tenuto \accent c \tenuto \accent r2. |
     r4. \mf es,8 r f r bes | 
     r g8 ~ g r8 f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" }  -. \accent \f r |
     r8 f8 -. \accent r2. |
     r4. g8 \mf r a ~ a4 |
     r8 g a -. r g a \tenuto ~ a r | \break
     r2r8 g a r | 
     r c \tenuto \accent ~ c4 r2 |
     r4. es,8 r f r bes | 
     r g ~ g r f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" } -. \accent \f r |
     r8 f8 -. \accent r2. |
    r4. g,8 \mf   r c r a' | 
     r g ~ g r e d e  r  | \break
     
     \set Score.skipBars = ##t R1*8 ^\markup { "Ya No Se" }
           
       r2 r8 c'8 ~-. \accent \f c4 |
       r2 r8 c,8  \mf \accent ~ c4 |
       r4. a'8 \f -. r a g g \accent -. |
       R1  | \break
       
       r2 r8 c8 ~-. \accent \f c4 |
       R1 |
       d,4 \mf ~ d8  \tenuto a'8 ~ a4 ~ a8 \tenuto bes ~ |
       bes4 ~ bes8  g8 \f  ~ g2 | \break
       \mark \markup { \musicglyph "scripts.coda" } 
      a8 ^\markup { "Chorus" }  -. \accent  r4. r8 g a -. r | 
     c \f \tenuto \accent c \tenuto \accent r2. |
     r4. \mf es,8 r f r bes | 
     r g8 ~ g r8 f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" }  -. \accent \f r |
     r8 f8 -. \accent r2. |
     r4. g8 \mf r a ~ a4 |
     r8 g a -. r g a \tenuto ~ a r | \break
     r2r8 g a r | 
     r c \tenuto \accent ~ c4 r2 |
     r4. es,8 r f r bes | 
     r g ~ g r f f bes,8 r  | \break
     r2. f'8 ^\markup { "Sax D" } -. \accent \f r |
     r8 f8 -. \accent r2. |
    r8 g8 \mf  \tenuto d \tenuto dis \tenuto  e \tenuto g \tenuto e \tenuto a -. \accent  |
    R1 | \break
    
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trombone (C, E, F, G)" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Sax" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Piano" } |
    r1 \fermata ^\markup { "Wait for apel" } | |
    
    g8 \f g -. r g -. r g ~ g4 \tenuto  ^\markup { "D.S. al Coda" } | \break

\repeat volta 4 {
     \set Score.skipBars = ##t R1*2 ^\markup { "Coda1 4x" } |
     c,8 c r a r c r d |
     r es r e r g a g |   \break
}
\repeat volta 4 {
     c,8  ^\markup { "Coda2 3x" } c r a r c r d \fermata ^\markup { "wait on D on 3rd" } |
     r es r e r g a g |   \break 
}

 c,8 c r a r c r d |
     r es r e r g a g |   
     c8 \accent r8 r2. |
    
    \bar "|."  
}


Chords = \chords {
  R1*16

  a1:m  | a:m |  c  |  c  |
  a:m  | a:m  | f4 g2 c4 | c1  |
  a1:m  | a:m |  c  |  c  |
  f  | f | g | g  | \break
  c | c | es | es |
  bes | bes | c | c |
}

\score {
    \compressMMRests \new StaffGroup <<
        %\new Staff << \Trumpet >>
        %\new Staff << \Saxophone >>
        \new Staff << \Trombone >>
        %\new PianoStaff <<
        %  \new Staff = "upper" \upper
        %  \new Staff = "lower" \lower
        %>>
        %\Chords
        %\new Staff << \Bass >>
        %\new DrumStaff \with {
        %  drumStyleTable = #congas-style
        %  \override StaffSymbol.line-count = #2
        %  \override BarLine.bar-extent = #'(-1 . 1)
        %}
        %<<
        %  \Congas
        %>>
        %\new DrumStaff \with {
        %  drumStyleTable = #timbales-style
        %  \override StaffSymbol.line-count = #2
        %  \override BarLine.bar-extent = #'(-1 . 1)
        %}
        %<<
        %  \Timbales
        %>>
    >>
    \layout {
    }
}

\score {
   %\compressMMRests \unfoldRepeats {
        \new StaffGroup <<
            %\new Staff << \Trumpet >>
            %\new Staff << \Saxophone >>
            \new Staff << \Trombone >>
            %\new PianoStaff <<
            %  \set PianoStaff.instrumentName = #"Piano  "
            %  \new Staff = "upper" \upper
            %  \new Staff = "lower" \lower
            %>>
            %\new Staff << \Bass >>
            %\new DrumStaff \with {
            %  drumStyleTable = #congas-style
            %  \override StaffSymbol.line-count = #2
            %  \override BarLine.bar-extent = #'(-1 . 1) 
            %}  
            %<<
            %  \Congas
            %>>
            %\new DrumStaff \with {
            %  drumStyleTable = #timbales-style
            %  \override StaffSymbol.line-count = #2
            %  \override BarLine.bar-extent = #'(-1 . 1)
            %}
            %<<
            %  \Timbales
            %>>
        >>
    \midi {
    }
}