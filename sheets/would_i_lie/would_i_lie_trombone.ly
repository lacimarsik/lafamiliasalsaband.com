\version "2.19.83"

\header {
    title = "Would I Lie"
    composer = "Cubaneros"
    arranger = "Ladislav Maršík"
    instrument = "trombone"
    copyright = "© La Familia Salsa Band 2022"
}

%\transpose c d
Trumpet = \new Voice \transpose c d \relative c' {
    \set Staff.instrumentName = \markup {
	\center-align { "Trom. in Bb" }
    }
    \set Staff.midiInstrument = "trumpet"

    \key c \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    	
    R1*14 ^\markup { "A Capella" }
    
    \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
    g r8 c,8 c4 r |
    
    r4. ^\markup { "Chorus" } as4 r8 c4 ~ |
    c2 r |
    r4. as4 r8 c4 ~ |
    c2 r |
    r4. g8 g r c4 ~ |
    c2 r |
    r4. g8 g r bes4 ~ |
    bes2 r |
    
    c4 r8 es8 es r as4 ~ |
    as2 r |
    f4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 es es r g4 ~ |
    g4 r2. |
    es4 r8 g g r bes4 ~ |
    bes2. r4 | \break
    
    R1*12 ^\markup { "Verse 1" } 
    
    es4 d4. r8 c4 ~ |
    c1 |
    R1 | 
    
    r4 f2. \> |
    R1*3 \! | 
    
    r2 f 8 -> r f4 ~ -> \sp \< |
    f1 ~ \! |
    f2 r4 es ~ 
    es1 |
    r2 bes8 -> bes -> r4 |
    
    r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
    c2 r |
    r4. as4 r8 c4 ~ |
    c2 r |
    r4. g8 g r c4 ~ |
    c2 r |
    r4. g8 g r bes4 ~ |
    bes2 r |
    
    c4 r8 es8 es r as4 ~ |
    as2 r |
    f4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 es es r g4 ~ |
    g4 r2. |
    es4 r8 g g r bes4 ~ |
    bes2. r4 | \break
    
    R1*12 ^\markup { "Verse 2" } 
    
    es4 d4. r8 c4 ~ |
    c1 |
    R1 | 
    
    R1 |
    R1*2 |
    r4 c,8 -. r r c -. r4 |
    c8 -. r c8 -. r r4 -. g'4 ~ -> \sp \< |
    g1 ~ |
    g2 \! r4 as -> \sp \< ~ 
    as1 ~ |
    as2 \! r4 as4 -> |
    
    r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
    c2 r |
    r4. as4 r8 c4 ~ |
    c2 r |
    r4. g8 g r c4 ~ |
    c2 r |
    r4. g8 g r bes4 ~ |
    bes2 r |
    
    c4 r8 es8 es r as4 ~ |
    as2 r |
    f4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 es es r g4 ~ |
    g4 r2. |
    es4 r8 g g r bes4 ~ |
    bes2. r4 | \break
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Trombone solo" }
    
    c'1 ~ ( \pp \< |
    c2. ~ c8 bes \mf ~ |
    bes1 \> ~ |
    bes4 \bendAfter #-2 g2 \p ) \bendAfter #-4 r4 |
    
    r8 g, \f as c es es c as |
    g r as c r es r f |
    r g, as c f f c as |
    g r as c r f r g ~ |
    g2 \bendAfter #-3 r2 |
    
    \set Score.skipBars = ##t R1*3 \break
    
    \set Score.skipBars = ##t R1*16 ^\markup { "Would I Lie" } \break
    
    \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
    r2. g,4 ~ -> \sp \< |
    g1 ~ |
    g2 \! r4 as -> \sp \< ~ 
    as1 ~ |
    as2 \! r2 |
    
    as8 -> as -> r4 as8 -> as -> r4 |
    \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. | \break
    
    r4. ^\markup { "Chorus" } as,4 r8 c4 ~ |
    c2 r |
    r4. as4 r8 c4 ~ |
    c2 r |
    r4. g8 g r c4 ~ |
    c2 r |
    r4. g8 g r bes4 ~ |
    bes2 r |
    
    c4 r8 es8 es r as4 ~ |
    as2 r |
    f4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 es es r g4 ~ |
    g2 r4 f' -> ~ \< |
    f1 ~ |
    f2 \! r2 | \break
    
    \bar "|."
}

%\transpose es c
Saxophone = \new Voice \transpose es c \relative c''' {
    \set Staff.instrumentName = \markup {
        \center-align { "Sass. in Eb" }
    }
    \set Staff.midiInstrument = "alto sax"

    \key c \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    	
    R1*14 ^\markup { "A Capella" }
    
    \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es} | 
    g r8 c8 c4 r |
    
    r4. ^\markup { "Chorus" } c,,4 r8 es4 ~ |
    es2 r |
    r4. c4 r8 f4 ~ |
    f2 r |
    r4. c8 c r es4 ~ |
    es2 r |
    r4. bes8 bes r es4 ~ |
    es2 r |
    
    as,4 r8 c8 c r es4 ~ |
    es2 r |
    as,4 r8 c8 c r f4 ~ |
    f2 r |
    g,4 r8 c8 c r es4 ~ |
    es4 r2. |
    g4 r8 bes bes r es4 ~ |
    es2. r4 |
    
    R1*12 ^\markup { "Verse 1" } 
    
    bes4 bes4. r8 a4 ~ |
    a1 |
    R1 |
    
    r4 f2. \> |
    R1*2 \! |
    r4 es8 -. r r d -. r4 |
    es8 -. r f8 -. r c' -> r -. b4 ~ -> \sp \< |
    b1 ~ \! |
    b2 r4 c4 ~ |
    c1 | 
    r2 bes8 -> bes -> r4 |
    
    r4. ^\markup { "Chorus" } c,4 r8 es4 ~ |
    es2 r |
    r4. c4 r8 f4 ~ |
    f2 r |
    r4. c8 c r es4 ~ |
    es2 r |
    r4. bes8 bes r es4 ~ |
    es2 r |
    
    as,4 r8 c8 c r es4 ~ |
    es2 r |
    as,4 r8 c8 c r f4 ~ |
    f2 r |
    g,4 r8 c8 c r es4 ~ |
    es4 r2. |
    g4 r8 bes bes r es4 ~ |
    es2. r4 |
    
    R1*12 ^\markup { "Verse 2" } 
    
    bes4 bes4. r8 a4 ~ |
    a1 |
    R1 |
   
    R1 | 
    R1*2 |
    r4 bes,8 -. r r bes -. r4 |
    a8 -. r a8 -. r r4 -. f'4 ~ -> \sp \< |
    f1 ~ |
    f2 \! r4 es4 ~ -> \sp \< |
    es1 ~ | 
    es2 \! r4 as4 -> |
    
    r4. ^\markup { "Chorus" } c,4 r8 es4 ~ |
    es2 r |
    r4. c4 r8 f4 ~ |
    f2 r |
    r4. c8 c r es4 ~ |
    es2 r |
    r4. bes8 bes r es4 ~ |
    es2 r |
    
    as,4 r8 c8 c r es4 ~ |
    es2 r |
    as,4 r8 c8 c r f4 ~ |
    f2 r |
    g,4 r8 c8 c r es4 ~ |
    es4 r2. |
    g4 r8 bes bes r es4 ~ |
    es2. r4 |
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Trombone solo" }
    
    g1 ~ ( \pp \< |
    g2. ~ g8 g8 \mf ~ |
    g1 \> ~ |
    g4 \bendAfter #-2 es2 \p ) \bendAfter #-4 r4 |
    
    r8 b, \f c es as as es c |
    b r c es r as r as |
    r b, c f as as f c |
    b r c f r as r c ~ |
    c2 \bendAfter #-3 r2 |
    
    \set Score.skipBars = ##t R1*3
    
    \set Score.skipBars = ##t R1*16 ^\markup { "Would I Lie" }
    
    \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
    
    r2. d,4 ~ -> \sp \< |
    d1 ~ |
    d2 \! r4 c4 ~ -> \sp \< |
    c1 ~ |  
    c2 \! r2 |
    
    as'8 -> as -> r4 as8 -> as -> r4 |
    \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. |
    
    r4. ^\markup { "Chorus" } c,4 r8 es4 ~ |
    es2 r |
    r4. c4 r8 f4 ~ |
    f2 r |
    r4. c8 c r es4 ~ |
    es2 r |
    r4. bes8 bes r es4 ~ |
    es2 r |
    
    as,4 r8 c8 c r es4 ~ |
    es2 r |
    as,4 r8 c8 c r f4 ~ |
    f2 r |
    g,4 r8 c8 c r es4 ~ |
    es2 r4 a, -> ~ \< |
    a1 ~ |
    a2 \! r2 |
    
    \bar "|."
}

Trombone = \new Voice \relative c {
    \set Staff.instrumentName = \markup {
      \center-align { "Trombone" }
    }
    \set Staff.midiInstrument = "trombone"
    \set Staff.midiMaximumVolume = #1.0

    \clef bass
    \key c \minor
    \time 4/4
    \tempo "Allegro" 4 = 180
    
    \set Score.skipBars = ##t R1*14 ^\markup { "A Capella" }
    
    \tuplet 3/2 { c4 c c } \tuplet 3/2 { es es es } | 
    g r8 es8 es4 r | \break
    
    as,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
    as2 r |
    f,4 r8 f'4 r8 as4 ~ |
    as2 r |
    c,4 r8 es8 es r g4 ~ |
    g2 r |
    bes,4 r8 es8 es r g4 ~ |
    g2 r | \break
    
    es4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 f8 f r as4 ~ |
    as2 r |
    c,4 r8 g'8 g r c4 ~ |
    c4 d2 bes4 ~ |
    bes2 r4 g'4 ~ |
    g2 r2 | \break
    
    R1*11 ^\markup { "Verse 1" } 
    
    g,4 g4. r8 f4 ~ |
    f1 |
    R1 |
    R1 |
    
    r4 f,2. \> |
    R1*2 \! |
    r4 c'8 -. r r bes -. r4 |
    c8 -. r d8 -. r c' -> r -. d4 ~ -> \sp \< |
    d1 ~ |
    d2 \! r4 es4 ~ |
    es1 |  
    r2 bes'8 -> bes -> r4 | \break
    
    as,,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
    as2 r |
    f,4 r8 f'4 r8 as4 ~ |
    as2 r |
    c,4 r8 es8 es r g4 ~ |
    g2 r |
    bes,4 r8 es8 es r g4 ~ |
    g2 r | \break
    
    es4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 f8 f r as4 ~ |
    as2 r |
    c,4 r8 g'8 g r c4 ~ |
    c4 d2 bes4 ~ |
    bes2 r4 g'4 ~ |
    g2 r2 | \break
    
    R1*11 ^\markup { "Verse 2" } 
    
    g,4 g4. r8 f4 ~ |
    f1 |
    R1 |
    R1 |
    
    R1 |
    R1*2 |
    r4 f8 -. r r f -. r4 |
    f8 -. r fis8 -. r r4 -. d'4 ~ -> \sp \< |
    d1 ~ |
    d2 \! r4 c4 ~ -> \sp \< |
    c1 ~ |  
    c2 \! r4 as, -> | \break
    
    as4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
    as2 r |
    f,4 r8 f'4 r8 as4 ~ |
    as2 r |
    c,4 r8 es8 es r g4 ~ |
    g2 r |
    bes,4 r8 es8 es r g4 ~ |
    g2 r | \break
    
    es4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 f8 f r as4 ~ |
    as2 r |
    c,4 r8 g'8 g r c4 ~ |
    c4 d2 bes4 ~ |
    bes2 r4 g'4 ~ |
    \set Staff.midiMaximumVolume = #2.0
    g2 r8 c, \f es c |
    es4. ^\markup { "Trombone solo" } es8 ~ es2 |
    r4. c8 bes c r es | 
    f4. c8 ~ c2 |
    r4. as8 g as c es |
    g1 -> ~ |
    g2 r8 g r \grace { fis16 } g8 -> ~ |
    g4. \> f8 es d r c |
    r bes ~ bes2. \p | 
    
    \set Staff.midiMaximumVolume = #1.0
    r8 g \f as c es es c as |
    g as r c r es r f |
    r g, as c f f c as |
    g as r c r f r g ~ |
    g2 r8 c r c ~ |
    c2 r2 |
    \set Staff.midiMaximumVolume = #2.0
    r8 ges f es f -> \grace { es } r f -> \grace { es } r |
    f r f ges f es c bes |
    f'4 ^\markup { "Would I Lie" } -> r2. |
    
    \set Staff.midiMaximumVolume = #1.0
    \set Score.skipBars = ##t R1*15
    
    \set Score.skipBars = ##t R1*3 ^\markup { "Te digo" }
    r2. g,4 ~ -> \sp \< |
    g1 ~ |
    g2 \! r4 as -> \sp \< ~ 
    as1 ~ |
    as2 \! r2 |
    
    as8 -> as -> r4 as8 -> as -> r4 |
    \tuplet 3/2 { as4 -> as -> as -> } as8 -> r4. | \break
    
    as,4 ^\markup { "Chorus" } r8 es'4 r8 as4 ~ |
    as2 r |
    f,4 r8 f'4 r8 as4 ~ |
    as2 r |
    c,4 r8 es8 es r g4 ~ |
    g2 r |
    bes,4 r8 es8 es r g4 ~ |
    g2 r | \break
    
    es4 r8 as8 as r c4 ~ |
    c2 r |
    c,4 r8 f8 f r as4 ~ |
    as2 r |
    c,4 r8 g'8 g r c4 ~ |
    c2 r4 f, -> ~ \< |
    f1 ~ |
    f2 \! r2 |
    
    \set Staff.midiMaximumVolume = #2.0
    r2 ^\markup { "Montuno - Petas" } r8 c \f es \tenuto f \tenuto |
    as \tenuto -> c, f \tenuto g -> \tenuto ~ g2 ~ |
    g2 ~ g8 f \tenuto -> \> r es \tenuto |
    d2 \tenuto \mf ~ d8 ( es \< f g -> \f ) ~ |
    g1 \> |
    r1 \mf | 
    c4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
    g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
    
    r2 r8 c' \f es \tenuto f \tenuto |
    as \tenuto -> g f \tenuto g -> \tenuto ~ g2 ~ |
    g2 ~ g8 f \tenuto -> \> r es \tenuto |
    d2 \tenuto \mf ~ d8 ( es \< f es -> \f ) ~ |
    es1 \> ~ |
    es2 \mf r2 | 
    c1 -> \sp \< ~ |
    c2 ~ c8 ( es c f -> \f ~ |
    f4 ^\markup { "coro pregon" } ) r2. |
    R1 |
    d1 ~ -> \sp \< |
    d1 |
    es1 ~ -> \! \sp \< |
    es1 |
    f1 -> \! \sp \< |
    r2 \! c8 \mf ( es c f -> \f ~ |
    f4 ) r2. |
    R1 |
    d1 ~ -> \sp \< |
    d1 |
    es1 ~ -> \! \sp \< |
    es1 |
    c,4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
    g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
    
    R1 |
    R1 |
    d''1 ~ -> \sp \< |
    d1 |
    es1 ~ -> \! \sp \< |
    es1 |
    f1 -> \! \sp \< |
    r2 \! c8 \mf ( es c f -> \f ~ |
    f4 ) r2. |
    R1 |
    d1 ~ -> \sp \< |
    d1 |
    es1 ~ -> \! \sp \< |
    es1 |
    c,4 \sf -> \bendAfter #-4 r bes4 \sf -> \bendAfter #-4 r | 
    g4 \sf -> \bendAfter #-4 r f4 \sf -> \bendAfter #-4 r | 
     
    \set Staff.midiMaximumVolume = #1.0  
    
    R1 ^\markup { "fade out" } |
    R1 |
    R1 |
    R1 |
    R1 |
    R1 |
    f''1 -> \! \sp \< |
    r2 \! r8 \mf es ( c f -> \f ~ |
    f4 ) ^\markup { "A Capella" } r2. |
    \set Score.skipBars = ##t R1*7
      
    \bar "|."  
}

Congas = \new DrumVoice \drummode {
  
    \set DrumStaff.instrumentName = \markup {
        \center-align { "Conga" }
    }

    \time 4/4
    \tempo "Allegro" 4 = 180
    	
    R1*14 ^\markup { "A Capella" }    
    
    \tuplet 3/2 { cgh4 cgh cgh } \tuplet 3/2 { cgh cgh cgh } | 
    cgh r8 cgh8 cgh4 r |
    
    \repeat percent 8 {
      bol8 ^\markup { "(tumbao 3/2)" } bolm ssh cglo cglo bolm cgho cgho |
      bolm bolm ssh bolm bolm bolm cgho cgho |
    }
    
    
    \repeat percent 8 {
      bolm8 ^\markup { "Verse 1 (tumbao + maracas)" } bolm ssh cglo cglo bolm cgho cgho |
      bolm bolm ssh bolm bolm bolm cgho cgho |
    }
    
    cgh8 ^\markup { "(tumbao + martillo + cascara 2-3)" } bolm ssh bolm cgh bolm cglo bolm |
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm cglo bolm |
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm r4 |
    R1 |
    R1 |
    
    \repeat percent 8 {
      cgh8 ^\markup { "(tumbao 3/2)" } bolm ssh cglo cglo cgh cgho cgho |
      cgh bolm ssh bolm cgh bolm cgho cgho |
    }
    
    \repeat percent 8 {
      bolm8 ^\markup { "Verse 2 (tumbao + maracas)" } bolm ssh cglo cglo bolm cgho cgho |
      bolm bolm ssh bolm bolm bolm cgho cgho |
    }
    
    cgh8 ^\markup { "(tumbao + martillo + cascara 2-3)" } bolm ssh bolm cgh bolm cglo bolm |
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm cglo bolm |
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm cglo bolm |
    
    cgh bolm ssh bolm cgh bolm r4 |
    R1 |
    R1 |
    
    \repeat percent 8 {
      bol8 ^\markup { "(tumbao 3/2)" } bolm ssh cglo cglo bolm cgho cgho |
      bolm bolm ssh bolm bolm bolm cgho cgho |
    }
    
    \repeat percent 8 {
      bol8 ^\markup { "(tumbao 3/2)" } bolm ssh cglo cglo bolm cgho cgho |
      bolm bolm ssh bolm bolm bolm cgho cgho |
    }
    
    \repeat percent 6 {
      bol8 ^\markup { "(conga tumbao slaps + guiro)" } bolm ssh r r bolm cgho cgho |
      bolm bolm ssh r r bolm cgho cgho |
    }
    
    ssh -> r r2. |
    \set Score.skipBars = ##t R1*3
    
    \repeat percent 4 {
      cglo8 ^\markup { "Te digo" } r cglo r cglo r cglo r |
      cglo r cglo r cglo r cglo r |
    }
    cgho cgho cglo r cgho cgho cglo r |
    \tuplet 3/2 { cgho4 cgho cgho } cgho8 cglo r4 |
    
    \repeat percent 8 {
      cgh8 ^\markup { "(tumbao 3/2)" } bolm ssh cglo cglo cgh cgho cgho |
      cgh bolm ssh bolm cgh bolm cgho cgho |
    }
    
    \bar "|."
}

Timbales = \new DrumVoice \drummode {
    \set Staff.instrumentName = \markup {
        \center-align { "Timbales" }
    }

    \time 4/4
    \tempo "Allegro" 4 = 180

    R1*14 ^\markup { "A Capella" }
    
    \tuplet 3/2 { cb4 cb cb } \tuplet 3/2 { cb cb cb} | 
    timh r8 timl8 timl4 cymc -^ |
    
    \repeat percent 8 {
      r8 ^\markup { "(campana 3/2)" } cb cb cb cb r cb cb |
      cb r cb r cb cb cb cb |
    }
    
    R1*16 ^\markup { "Verse 1 (tumbao + maracas)" } 
    
    
    hhc8-. ^\markup { "(tumbao + martillo + cascara 2-3)" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
    
    hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
    
    hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
    
    r2 timh8 timh r timh |
    r timh timl timl cb -^ cb -^ r4 |
    
    \repeat percent 8 {
      r8 ^\markup { "(campana 3/2)" } cb cb cb cb r cb cb |
      cb r cb r cb cb cb cb |
    }
    
    R1*16 ^\markup { "Verse 2 (tumbao + maracas)" } 
    
    hhc8-. ^\markup { "(tumbao + martillo + cascara 2-3)" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
    
    hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
    
    hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
    
    hhc8-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
    timh timl r timl r timl cymc4 -^ |
    
    \repeat percent 8 {
      r8 ^\markup { "(campana 3/2)" } cb cb cb cb r cb cb |
      cb r cb r cb cb cb cb |
    }
    
    \repeat percent 8 {
      r8 ^\markup { "(campana 3/2)" } cb cb cb cb r cb cb |
      cb r cb r cb cb cb cb |
    }
    
    rb8 -. ^\markup { "(camp. + contrac.)" } ^\markup { "Timbal Solo" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
    cymc -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
    cymc -^ ^\markup { "Timbal Solo" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho cymc -^ r cymc -^ r |
    cymc -^ r r2. |
    
    \set Score.skipBars = ##t R1*3
    
    
    hh8 ^\markup { "Te digo (hh / cymbal)" } r hh r hh r hh r |
    hh r hh r hh r hh r |
    hh r hh r hh r hh r |
    hh r hh r hh r cymc -^ r |
    hh r hh r hh r hh r |
    hh r hh r hh r hh r |
    hh r hh r hh r hh r |
    hh r hh r hh r hh r |
    
    timl timl cymc -^ r timl timl cymc -^ r |
    \tuplet 3/2 { timl4 timl timl } timl8 cymc -^ r4 |
    
    \repeat percent 6 {
      rb8 -. ^\markup { "(camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
      <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
    }
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb cymc4 -^ |
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
    
    \bar "|."
}

\score {
    \compressMMRests \new StaffGroup <<
        %\new Staff << \Trumpet >>
        %\new Staff << \Saxophone >>
        \new Staff << \Trombone >>
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
