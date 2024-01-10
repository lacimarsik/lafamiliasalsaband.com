\version "2.24.0"

% Sheet revision 2022_09


\header {
  title = "Ain't Nobody"
  instrument = "sax"
  composer = "by Alex Wilson feat. AQuilla Fearon"
  arranger = "arr. Ladislav Maršík"
  opus = "version 1.11.2023"
  copyright = "© La Familia Salsa Band"
}

inst =
#(define-music-function
  (string)
  (string?)
  #{ <>^\markup \abs-fontsize #16 \bold \box #string #})

makePercent = #(define-music-function (note) (ly:music?)
                 (make-music 'PercentEvent 'length (ly:music-length note)))

#(define (test-stencil grob text)
   (let* ((orig (ly:grob-original grob))
          (siblings (ly:spanner-broken-into orig)) ; have we been split?
          (refp (ly:grob-system grob))
          (left-bound (ly:spanner-bound grob LEFT))
          (right-bound (ly:spanner-bound grob RIGHT))
          (elts-L (ly:grob-array->list (ly:grob-object left-bound 'elements)))
          (elts-R (ly:grob-array->list (ly:grob-object right-bound 'elements)))
          (break-alignment-L
           (filter
            (lambda (elt) (grob::has-interface elt 'break-alignment-interface))
            elts-L))
          (break-alignment-R
           (filter
            (lambda (elt) (grob::has-interface elt 'break-alignment-interface))
            elts-R))
          (break-alignment-L-ext (ly:grob-extent (car break-alignment-L) refp X))
          (break-alignment-R-ext (ly:grob-extent (car break-alignment-R) refp X))
          (num
           (markup text))
          (num
           (if (or (null? siblings)
                   (eq? grob (car siblings)))
               num
               (make-parenthesize-markup num)))
          (num (grob-interpret-markup grob num))
          (num-stil-ext-X (ly:stencil-extent num X))
          (num-stil-ext-Y (ly:stencil-extent num Y))
          (num (ly:stencil-aligned-to num X CENTER))
          (num
           (ly:stencil-translate-axis
            num
            (+ (interval-length break-alignment-L-ext)
               (* 0.5
                  (- (car break-alignment-R-ext)
                     (cdr break-alignment-L-ext))))
            X))
          (bracket-L
           (markup
            #:path
            0.1 ; line-thickness
            `((moveto 0.5 ,(* 0.5 (interval-length num-stil-ext-Y)))
              (lineto ,(* 0.5
                          (- (car break-alignment-R-ext)
                             (cdr break-alignment-L-ext)
                             (interval-length num-stil-ext-X)))
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (closepath)
              (rlineto 0.0
                       ,(if (or (null? siblings) (eq? grob (car siblings)))
                            -1.0 0.0)))))
          (bracket-R
           (markup
            #:path
            0.1
            `((moveto ,(* 0.5
                          (- (car break-alignment-R-ext)
                             (cdr break-alignment-L-ext)
                             (interval-length num-stil-ext-X)))
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (lineto 0.5
                      ,(* 0.5 (interval-length num-stil-ext-Y)))
              (closepath)
              (rlineto 0.0
                       ,(if (or (null? siblings) (eq? grob (last siblings)))
                            -1.0 0.0)))))
          (bracket-L (grob-interpret-markup grob bracket-L))
          (bracket-R (grob-interpret-markup grob bracket-R))
          (num (ly:stencil-combine-at-edge num X LEFT bracket-L 0.4))
          (num (ly:stencil-combine-at-edge num X RIGHT bracket-R 0.4)))
     num))

#(define-public (Measure_attached_spanner_engraver context)
   (let ((span '())
         (finished '())
         (event-start '())
         (event-stop '()))
     (make-engraver
      (listeners ((measure-counter-event engraver event)
                  (if (= START (ly:event-property event 'span-direction))
                      (set! event-start event)
                      (set! event-stop event))))
      ((process-music trans)
       (if (ly:stream-event? event-stop)
           (if (null? span)
               (ly:warning "You're trying to end a measure-attached spanner but you haven't started one.")
               (begin (set! finished span)
                 (ly:engraver-announce-end-grob trans finished event-start)
                 (set! span '())
                 (set! event-stop '()))))
       (if (ly:stream-event? event-start)
           (begin (set! span (ly:engraver-make-grob trans 'MeasureCounter event-start))
             (set! event-start '()))))
      ((stop-translation-timestep trans)
       (if (and (ly:spanner? span)
                (null? (ly:spanner-bound span LEFT))
                (moment<=? (ly:context-property context 'measurePosition) ZERO-MOMENT))
           (ly:spanner-set-bound! span LEFT
                                  (ly:context-property context 'currentCommandColumn)))
       (if (and (ly:spanner? finished)
                (moment<=? (ly:context-property context 'measurePosition) ZERO-MOMENT))
           (begin
            (if (null? (ly:spanner-bound finished RIGHT))
                (ly:spanner-set-bound! finished RIGHT
                                       (ly:context-property context 'currentCommandColumn)))
            (set! finished '())
            (set! event-start '())
            (set! event-stop '()))))
      ((finalize trans)
       (if (ly:spanner? finished)
           (begin
            (if (null? (ly:spanner-bound finished RIGHT))
                (set! (ly:spanner-bound finished RIGHT)
                      (ly:context-property context 'currentCommandColumn)))
            (set! finished '())))
       (if (ly:spanner? span)
           (begin
            (ly:warning "I think there's a dangling measure-attached spanner :-(")
            (ly:grob-suicide! span)
            (set! span '())))))))

\layout {
  \context {
    \Staff
    \consists #Measure_attached_spanner_engraver
    \override MeasureCounter.font-encoding = #'latin1
    \override MeasureCounter.font-size = 0
    \override MeasureCounter.outside-staff-padding = 2
    \override MeasureCounter.outside-staff-horizontal-padding = #0
  }
}

repeatBracket = #(define-music-function
                  (parser location N note)
                  (number? ly:music?)
                  #{
                    \override Staff.MeasureCounter.stencil =
                    #(lambda (grob) (test-stencil grob #{ #(string-append(number->string N) "x") #} ))
                    \startMeasureCount
                    \repeat volta #N { $note }
                    \stopMeasureCount
                  #}
                  )

Sax = \new Voice
\transpose c a'
%\transpose c d
\relative c' {
  \set Staff.instrumentName = \markup {
    \center-align { "Sax in Bb" }
  }
  \set Staff.midiInstrument = "alto sax"
  \set Staff.midiMaximumVolume = #0.9

  \key e \minor
  \time 4/4
  \tempo "Medium Fast Salsa" 4 = 190

  R1 ^\markup { "Timbales Roll" }
  
  \inst "in"
  \repeat volta 2 { 
    d,8 \f -- d -- cis -- d --  r b -. r b -. |
    r b -. r2. |
    e4. \mf -- d8 e4. -- fis8  |
    g4. -- fis8 e4. -- d8 |
    e1 \sp \< ~ |
    e2. r4 \f \! |
    e4. \mf -- d8 e4. -- fis8  |
  }
    \alternative { 
    {
      g4. -- fis8 e ( a, \< b c \! ) |
    } 
    {
      g'4. -- fis8 e4. -- d8 |
    }
  }
  \break
  b1 \p \< ~ |
  b1 |
  b1 \p \< ~ |
  b1 |
  b1 \! \p \< ~ |
  b1 |
  b1  \! \mf \< ~ |
  b1 \! \f |
  
  \inst "A1"
  \set Score.skipBars = ##t R1*16 ^\markup { "Verse 1" }
  
  \inst "B1"
  \set Score.skipBars = ##t R1*8 ^\markup { "Pre-Chorus" }
  
  \break
  \inst "A2" 
  g'1 \p ^\markup { "Verse 2" }  ~ |
  g1  |
  g1 \< ~ |
  g4.\mp -- fis4. -- e4 -- ~ \> |
  e1 |
  R1 * 3 \pp \! | \break
  R1 * 2
  b'1 \! \fp \< ||
  d,4.\! \mp -- e4. -- b'4 ~ \< |
  b2 a4 -. a4 -. |
  b4. -- b8 -. r c -. r c -. \mf \! |
  R1 * 2
  \break
  \inst "B2"
  d,1 ^\markup { "Pre-Chorus" } \fp \< ~ |
  d2. ~ d8 fis \! \fp \< ~ |
  fis1 ~ |
  fis1 |
  b,1 \p \< ~ |
  b1 |
  R1*2 \! \mf
  \break
  s1 * 0
  ^\markup { "Chorus 1" }
  \inst "C1"
  g'4 \accent \ff r2. |
  fis,4. -- \mf g4. -- a4 -- ~ \fp \< |
  a1 |
  r2 r8 b8 \ff -- b -- b -- |
  g' -- g -- g -- r8 r2 |
  r2 r8 b -. \mp r a ~ \< |
  a2. r4 \! \mf |
  b,8 \f \! -. r r b -. r r g'4 \ff \accent |
  R1*4
  
  \break
  b,1 \p \< ~ |
  b1 |
  b1  \! \mf \< ~ |
  b1 \! \f |
  \break

  \inst "A3"
  R1 * 5 ^\markup { "Verse 3" } 
  fis'4. \mp -- c8 -. r fis -. r  d -. |
  R1 * 2 \break
  R1 * 3
  e4.\! \mp -- fis4. -- a4 ~ \< ||
  a2 a4 -. a4 -. |
  b4. -- b8 -. r c -. r c -. \mf \! |
  R1 * 2 \break

  \inst "B3"
  d,1 ^\markup { "Pre-Chorus" } \fp \< ~ |
  d1 |
  fis1 \! \fp \< ~ |
  fis1 |
  b,1 \p \< ~ |
  b1 |
  R1*2 \! \mf \break
  
    \inst "C2"
    s1*0 ^\markup { "Chorus 2" }
   g'4 \accent \ff r2. |
  fis,4. -- \mf g4. -- a4 -- ~ \fp \< |
  a1 |
  r2 r8 b8 \ff -- b -- b -- |
  g' -- g -- g -- r8 r2 |
  r2 r8 b -. \mp r a ~ \< |
  a2. r4 \! \mf |
  b,8 \f \! -. r r b -. r r g'4 \ff \accent | \break
  R1 |
  fis,4. -- \mf g4. -- a4 -- ~ \fp \< |
  a1 |
  r2 r8 b8 \ff -- b -- b -- |
  e -- e -- e -- r8 r2 |
  r2 r8 b' -. \mp r a ~ \< |
  a2. r4 \! |
  c,4. -- \mf b4. -- gis4 -- \> ~ |
  gis1 ~ |
  gis2 \p r2 |
  R1 * 2 \break
  
  \inst "D/in"
  \repeat volta 2 { 
     d'8 \f -- d -- cis -- d --  r b -. r b -. |
    r b -. r2. |
    e4. -- d8 e4. -- fis8  |
    g4. -- fis8 e4. -- d8 |
    c2 \p \< ~ c8 c -- c -- c -> \f |
    r8 c -. r2.  |
    e4. -- d8 e4. -- fis8  |
    g4. -- fis8 e4. -- fis8 |
    d8 \f -- d -- cis -- d --  r b -. r b -. |
    r b -. r2. |
    R1*6 \break
  }
  
  \inst "E"
  r2 e4 \f -. e -. |
  g4. -- d4. r8 -- cis8 -> ~ |
  cis4 \bendAfter #-4 r2. |
  r8 b -- e -- e -- fis -- fis -- g4 -> ~ | \break
  
  \inst "C3"
  g2 ^\markup { "Petas - as Chorus" } e4 -. \mf e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) |
  r2 e4 -. e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) | \break
  r2 e4 -. \mf e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) |
  r2 e4 -. e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) |
  r2 e4 -. e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) | \break
  r2 e4 -. e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) |
  r2 e4 -. e -. |
  e8 ( d b a' -. ) r a ( fis d -. ) |
  r2 e4 -. e -. |
  e4. -- d4. -- e4 ~ -- | \break 
   \inst "C4"
  e2 ^\markup { "Chorus - No Brass" } r2 |
  R1 * 15 | 
  \inst "G"
  R1 * 16 ^\markup { "Coro y Pregón" }  | \break
  \inst "H"
  r8 b \mf ~ ^\markup { "Petas + Pregón" } b8 b -. d ( e g e ~ ) |
  e1 |
  R1 * 3 |
  r8 b \mf ( e fis g fis e d ) |
  a' \f -- a -- a -- e16 ( \< fis g8 -. ) fis16 ( g a8 -. ) g16 ( a |
  b8 \ff -> \> g e a8 ) ~ a4 \bendAfter #-4 -> \f r4 | \break
  r8 b, \mf ~ b8 b -. d ( e g e ~ ) |
  e1 |
  R1* 2  |
  r8 b \mf ( e fis g fis e ) a \< -- ~ |
  a g fis b \f -- ~ b a16 g fis8 -. d -. |
  e1 \sp \< -> |
  c'2. \f -> b4 -> \ff |
  
  \label #'lastPage
  \bar "|."  
  
  
  \label #'lastPage
  \bar "|."  
  
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \Sax
  }
  \layout {
    \context {
      \Score
      \remove "Volta_engraver"
    }
  }
}


\paper {
  system-system-spacing =
  #'((basic-distance . 14)
     (minimum-distance . 10)
     (padding . 1)
     (stretchability . 60))
  between-system-padding = #2
  bottom-margin = 5\mm

  print-first-page-number = ##t
  oddHeaderMarkup = \markup \fill-line { " " }
  evenHeaderMarkup = \markup \fill-line { " " }
  oddFooterMarkup = \markup {
    \fill-line {
      \bold \fontsize #2
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }

      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }
    }
  }
  evenFooterMarkup = \markup {
    \fill-line {
      \fontsize #-1
      \concat { \fromproperty #'header:title " - " \fromproperty #'header:instrument ", " \fromproperty #'header:opus ", " \fromproperty #'header:copyright }

      \bold \fontsize #2
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
    }
  }
}