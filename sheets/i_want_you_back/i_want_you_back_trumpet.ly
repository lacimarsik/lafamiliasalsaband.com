\version "2.19.83"

\header {
    title = "I Want You Back"
    composer = "Tony Succar feat. Tito Nieves"
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
    	
    R1*8 ^\markup { "Guitar + Sax" }
    
    es4 -. r2. |
    r4. es8 g bes c as -. |
    r8 f8 g as ~ as a bes h |
    c4 g as4. es8 ~ |
    f2 bes4. es,8 |
    
    
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
