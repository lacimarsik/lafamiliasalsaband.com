\version "2.22.2"

\header {
    title = "Sera Que No Me Amas"
    instrument = "bass"
    composer = "Tony Succar feat. Michael Stuart"
    arranger = "Ladislav Maršík"
    opus = "version: 20220802_BASS_S22"
    copyright = "© La Familia Salsa Band 2022"
}

inst =
#(define-music-function
   (string)
   (string?)
   #{ <>^\markup \abs-fontsize #16 \bold \box #string #})

makePercent =
#(define-music-function (note) (ly:music?)
   (make-music 'PercentEvent
               'length (ly:music-length note)))

Bass = \new Voice \relative c {
    \set Staff.instrumentName = \markup {
      \center-align { "Bass" }
    }
    \set Staff.midiInstrument = "acoustic bass"
    \set Staff.midiMaximumVolume = #1.5

    \clef bass
    \key a \minor
    \time 4/4
    \tempo "Allegro" 4 = 180

    <>^\markup { "Intro" }
    \inst "A"
    c4 c e e |
    r8 a r e r e d r |
    r4. d8 d r r e |
    r f r fis r g a g | \break
    c4  c e, e |
    r8 a r e r e d r |
    r4. d8 d r r e |
    r f r fis r g a g | \break
    c4  c e, e |
    r8 a r e r e d r |
    r4. d8 d r r e |
    r f r fis r g a g | \break
    c4  c e, e |
    r8 a r e r e d r |
    r4. d8 d r r e |
    r f r fis g2 | \break
    \mark \markup { \musicglyph "scripts.segno" }
    <>^\markup { "Verse 1 & 3" }
    \inst "B"
    a,4 r r8 e' r a |
    r g r d r e c r |
    r4. bes8 ~ bes2 |
    r8 c r4 g2 | \break
    a4 r g8 a r4 |
    r d,4 ~ d r |
    f4 g ~ g c ~ |
    c1 |
    <>^\markup { "Salsa" }
    \repeat percent 8 { \makePercent s1 }
    \break
    <>^\markup { "Chorus 1 & 3" }
    \inst "C"
    \repeat percent 8 { \makePercent s1 }
    \break
    \makePercent s1 |
    r8 f,8 ~ f2. |
    \repeat percent 6 { \makePercent s1 }
    \break
    a4 ^\markup { "Verse 2 & 4" }     r r8 e' r a |
    r g r d r e c r |
    r4. bes8 ~ bes2 |
    r8 c r4 g2 | \break
    a4 r g8 a r4 |
    r d,4 ~ d r |
    f4 g ~ g c ~ |
    c1 |
    <>^\markup { "Salsa" }
    \repeat percent 8 { \makePercent s1 }
    \break
    <>^\markup { "Chorus 2 & 4" }
    \repeat percent 8 { \makePercent s1 }
    \break
    \makePercent s1 |
    r8 f,8 ~ f2. |
    \repeat percent 6 { \makePercent s1 }
    \break
         
    <>^\markup { "Ya No Se (calm)" }
    \inst "D"
    \repeat percent 8 { \makePercent s1 }
    \break
         
    <>^\markup { "(salsa)" } 
    \repeat percent 6 { \makePercent s1 }
    d4. a'8 ~ a4. bes8 ~ |
    bes4. g8 ~ g2 |
    \mark \markup { \musicglyph "scripts.coda" } 
    
          R1*8 ^\markup { "Chorus" }   \break
         R1 |
         r8 f8 ~ f2. |
         R1*6    \break
         
         \break
          \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trombone (C, E, F, G)" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Sax" }
    \set Score.skipBars = ##t R1*16 ^\markup { "Solo Piano" } |
    r1 \fermata ^\markup { "Wait for apel" } | |
       g8 \f g -. r g -. r g ~ g4 \tenuto  ^\markup { "D.S. al Coda" } | \break

     R1*4 |\break

\repeat volta 4 {
     c8  ^\markup { "Coda2 3x" } c r a r c r d \fermata ^\markup { "wait on D on 3rd" } |
     r es r e r g a g |   \break 
}

 c,8 c r a r c r d |
     r es r e r g a g |   
     c,8 \accent r8 r2. |
    
    \bar "|."
    \bar "|."  
}

Chords = \chords {
  R1*24

  a1:m  | a:m |  c  |  c  |
  f  | f | g | g  | \break
  c | c | es | es |
  bes | bes | c | c |
    c | r  | es | es |
  bes | bes | c | c |
  
     R1*8
     
      a1:m  | a:m |  c  |  c  |
  f  | f | g | g  | \break
  c | c | es | es |
  bes | bes | c | c |
    c | r  | es | es |
  bes | bes | c | c |
  
  c  | e:m |  f  |  g  |
  c  | e:m |  f  |  g  | \break
  
    c  | a:m |  f  |  g  |
  c  | a:m | r  | r  \break
c | c | es | es |
  bes | bes | c | c |
    c | r  | es | es |
  bes | bes | c | c |
       R1*66
       
         c1  | e:dim |  f  |  g  |  \break
  
}

\score {
    \compressMMRests \new StaffGroup <<
        %\new Staff << \Trumpet >>
        %\new Staff << \Saxophone >>
        %\new Staff << \Trombone >>
        %\new PianoStaff <<
        %  \new Staff = "upper" \upper
        %  \new Staff = "lower" \lower
        %>>
        \Chords
        \new Staff << \Bass >>
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

%\score {
   %\compressMMRests \unfoldRepeats {
        %\new StaffGroup <<
            %\new Staff << \Trumpet >>
            %\new Staff << \Saxophone >>
            %\new Staff << \Trombone >>
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
        %>>
   %}
    %\midi {
    %}
%}