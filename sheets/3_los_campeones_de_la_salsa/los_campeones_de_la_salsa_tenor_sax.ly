\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "Los Campeones De La Salsa"
  instrument = "tenor sax"
  composer = "by Willy Chirino"
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

TenorSax = \new Voice
\transpose c d'
\relative c {
        \set Staff.instrumentName = \markup {
		\center-align { "T. Sax in Bb" }
	}
	
	  \clef treble
  \key c \minor
  \time 4/4
  \tempo "Faster Salsa" 4 = 185

	c'8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es f4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	g8 -\f g g g g4 -. r |
	R1 |
	g8 -\ff g g g g4 -> r8 c, \mp | 
	d -. r d b -. r b b -. r | \break
	\repeat volta 2 {
	    \set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	    g2. ~ g8 g'8 ~ -> |
	    g g f g f g16 f es4 -. |
	    c4 -> r r r8 c8 -. |
	    r4 r8 c d es4. |
	    c4 -. r r2 |
	    r4. c8 d es d es -. |
	    \set Score.skipBars = ##t R1*2
	    g,2. ~ g8 des'8 ~ -> |
	    des des4 -. es -. des4. |
	    c4 -> ^\markup { "Piano Break" } r r2 |
	    r2 r8 des4 -. es8 -\sfz -\< ~ |
	    es1 ~ |
	    es1 \ff |
	    \set Score.skipBars = ##t R1*14 ^\markup { "Verse 1 and 2" } | 
            r8 g -> -. r4 g -> -. r8 g -> -. |
            r4 r8 g -> g4 -> g4 -> -. | \break
	}
	\set Score.currentBarNumber = 93
	
	\set Score.skipBars = ##t R1*6 ^\markup { "Chorus" }
	g,2. ~ g8 g'8 ~ -> |
	g g f g f g16 f es4 -. |
	c4 -> r r r8 c8 -. |
	r4 r8 c d es4. |
	c4 -. r r2 |
	r4. c8 d es d es -. |
	\set Score.skipBars = ##t R1*2
	g,2. ~ g8 des'8 ~ -> |
	des des4 -. es -. des4. | \break
	
	c8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es g4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	as4 -. as -. as -. as -. |
	R1 |
	g4 -. g -. g -. g -. |
	r8 g4 -. as8 -> ~ as4 \bendAfter #-4 r4 | \break

	\set Score.skipBars = ##t R1*16 ^\markup { "E se soy yo" }
	
	\set Score.skipBars = ##t R1*8 ^\markup { "Trumpet" }

	\set Score.skipBars = ##t R1*16 ^\markup { "Reggaeton" } \break

	\set Score.skipBars = ##t R1*16 ^\markup { "E se sel mio" }

	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Trumpet" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Solo Saxophone" }
	
	\set Score.skipBars = ##t R1*16 ^\markup { "Chorus" } \break
	
	c,8 -> \ff ^\markup { "Intro" } d -. r c g'2 ~ |
        g2. r4 |
        c,8 -> d -. r c as'2 ~ |
        as2. r4 |
        c,8 -> d -. r c r4 b'8 b |
        r bes8 ~ bes bes ~ bes2 |
        g8 -> as -. r f g2 ~ |
        g2. r4 |

	r2 r4. es8 -. -\mf ~ |
	es f4 -. g4 -. es4. |
	r2 r4. es8 -. ~ |
	es g4 -. g4 -. es4. |
	r2 r4 f8 \ff g -. |
	r f8 ~ f as8 ~ as2 |
	g8 -\f g g g g4 -. r |
	R1 |
	g8 -\ff g g g g4 -> r8 c, \mp | 
	d -. r d b -. r b b -. r | \break
	c8 \ff ^\markup { "Coda" } c c c es4 -> c -> -. |
	R1 ^\markup { "5 = 2 bars" } |
	R1 |
	c8 \fff c c c -> -. r2 | 
	
	
  \label #'lastPage
	\bar "|."
}

\score {
  \compressMMRests \new Staff \with {
    \consists "Volta_engraver"
  }
  {
    \TenorSax
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

  print-page-number = ##t
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