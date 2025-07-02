\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#8 Un Monton de Estrellas (Latin Soul: A)"
  instrument = "trumpet"
  composer = "Polo Montañez / Gilberto Santa Rosa"
  arranger = "arr. Ladislav Maršík"
  opus = "version 25.8.2024"
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

Trumpet = \new Voice
\transpose c d % Ivar
\transpose c d'
\relative c' {
  \set Staff.instrumentName = \markup {
		\center-align { "Tr. in Bb" }
	}

	\key g \major
	\time 4/4

	\repeat volta 2 {

\inst "in1,2"
s1*0 ^\markup { "Intro Piano + Vocals" }
	R1*16

\inst "A1,2"
s1*0 ^\markup { "Verse 1 & 2" }
	R1*7

	r2 r8 d,4 -\staccato c8 |
	b4. d8 ~ d2 ~ |
	d2 r8 b4 -\staccato g8 |
	a4. c8 ~ c2 ~ |

	c4. b8 -\staccato r8 c8 -\staccato r8 d8 ~ |
	d4. g,8 ~ g2 ~ |
	g2 r2 |
	r8 d' -\staccato r fis -\staccato r a -\staccato r d -\accent ~ |

	d2 c4 -\staccato a4 -\staccato | \break
	
	\inst "B"
	b4 -\accent ^\markup { "Pre-Chorus 1 & 2" } r4 r2 |
            R1 | 
            r8 b8 -. ^^ r8 d8 -. ^^ r2 |
            r2 r4 r8 g,8 ~ -> 
            g4 e'8 -> [ e8 -. ^^ ] r2 | 
            R1 \break |
            r8 d8 -. r4.  d8 \mf d8 d8 \f -> |
            r4 d8 -. r c -. ^^ r d -. ^^ r \bar "||" 
            R1*2 |
            r8 b8 \mf \< -. r8 \grace { cis8 } d8~ \f \> -\accent d4 a8 g8~ \mp -\accent |
            g2 r2 |
            r8 b8 \mf \< -. r8 \grace { dis8 } e8~ \f \> -\accent e4 a,8 g8~ \mp -\accent |
            g2 r2 |
            R1 |
            r2 b8 \mf -. r c -. r \break
            \inst "C1,2"
            d8 -. ^^ ^\markup{ "Chorus 1 & 2" } r4 d8 -. ^^ r4 d8 \bendAfter #-4 -. ^^ r | 
            R1 |
            r2 r4 e,,8 \mp [ fis8 ] |
            g8 -. r a8 [ b8 -. ] r8 d8 -. r8 g8 \f ~ -> |
            g4. g8 -. ^^ r2 |
            R1*2 
            r8 d4 -> \tenuto r8 \grace { d8 [ a ] } g8 \mf -. r a8 -. r \break
            b8 -. ^^ r4 b8 -. ^^ r4 b8 \bendAfter #4 r |
            R1 |
	    R1 |
	    r2 r4 r8 g8 \mf \< -\staccato |
	    r b8 -\staccato r c -\staccato r d -\staccato r e8 \f -\accent ~ |
	    e4 \grace { f8 [ fis ] } g8 -. ^^ e8 -\staccato r g -. ^^ r4 |
            \set Score.skipBars = ##t R1*2

  	}
  	\inst "in3"
s1*0 ^\markup { "Intro" }
	R1*16
	s1*0 ^\markup { "Piano bomba" }
	R1*8 \break
	
  R1*48  \fermata ^\markup { \column { \line { "Forma: 4 Coro 3 Pregón, SOLO, 4 Coro 3 Pregón, SOLO, 4 Coro 3 Pregón" } } } \break
	
	
	
	        \repeat volta 2 {
            r2 ^\markup{ "*Possibility for Coro" } r8 b,8 \p \< [ c8 d8 -. ] |
            r8 b8 -. r8 g'8 \tenuto r8 d8 -. b'8 \mp  \tenuto r8 |
            g4 \p \tenuto r4 r2 |
            r8 fis8 \< -. r8 a8 ( -> \mp \> a8 ) [ e8 -- ] d4 \p -.
            r8 b8 -. \< r8 d8 -. g4 \mp -> r4 |
            R1*3 \break
        }

   
            \chordmode {
   R1*3 _\markup { "CORO --> SOLO" }
   r2.
 a,8 a, 
   R1 _\markup { "Start solo" } |
g,4. g,4. d,4 ~ |
d,1  |
e,1  |
  a,1 |
  g,1 |
  d,1 |
  e,1 | \break

}

  s1*0 ^\markup { "Coda" }
  d4 g d g |
  d8 d d d d r g g |
  \break

  \label #'lastPage
  \bar "|."
}

Chords =
\transpose c d'
\chords {
  \set noChordSymbol = ""
  R1*144
  

  a1 |
  g1 |
  d1 |
  e2. a4 |
  a1 |
  g1 |
  d1 |
  e1 |
  a1 |
  g1 |
  d1 |
  e1 |
}

\score {
  <<
    \Chords
    \compressMMRests \new Staff \with {
      \consists "Volta_engraver"
    }
    {
      \Trumpet
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