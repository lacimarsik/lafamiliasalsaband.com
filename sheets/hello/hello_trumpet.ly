\version "2.19.83"

\header {
    title = "Hello"
    composer = "Mandinga"
    arranger = "Ladislav Marsik"
    instrument = "trumpet"
    copyright = "© La Familia Salsa Band 2022"
}

%\transpose c d
Trumpet = \new Voice \transpose c d \relative c'' {
    \set Staff.instrumentName = \markup {
	\center-align { "Trom. in Bb" }
    }
    \set Staff.midiInstrument = "trumpet"

    \key c \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    	
    R1*8 ^\markup { "Piano" }
    
    R1*8 ^\markup { "Verse" }
    
    R1*6 ^\markup { "+ Bass & Percussions" }
    
    es4 -. es -.  es -. as \tenuto \fp \< ~ |
    as2.  r4  \! \f |
    R1 |
    r8 es -. r bes ~ bes2 |
    bes2 as8 bes c4 ~ |
    c2. r4 |
    
    \bar "|."
}


\score {
    \compressMMRests \new StaffGroup <<
        \new Staff << \Trumpet >>
        %\new Staff << \Saxophone >>
        %\new Staff << \Trombone >>
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
