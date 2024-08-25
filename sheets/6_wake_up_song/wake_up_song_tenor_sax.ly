\version "2.24.4"

% Sheet revision 2022_09

\header {
  title = "#6 Wake Up Song"
  instrument = "tenor sax"
  composer = "by La Familia Salsa Band"
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

TenorSax = \new Voice
\transpose c d'
\relative c {
    \set Staff.instrumentName = \markup {
        \center-align { "T. Sax in Bb" }
    }
    
      \clef treble
  \key b \minor
  \time 4/4
  \tempo "Faster Salsa" 4 = 185

    \repeat volta 2 {
        fis'8 -> -\f ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
        g8 -> -. r r a8 -> -. r r fis4~ ->  |
        fis4. e8 -\mf \< ( ~ e4  f8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Piano Montuno" }
        g8 -\f -> -. r r a8 -> -. r r fis4~ ->  |
    }
    \alternative {
        {
            fis2. r4
        }
        {
            fis4. e8 -\mf \< ( ~ e4  f8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        fis8 -> -\f ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
        g8 -> -. r r a8 -> -. r r fis4~ ->  |
        fis4. e8 -\mf \< ( ~ e4  f8 ) r \! |
        \break |
    }
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*2 ^\markup { "Coro" }
        g8 -\f -> -. r r a8 -> -. r r fis4~ ->  |
    }
    \alternative {
        {
            fis2. r4
        }
        {
            fis4. e8 -\mf \< ( ~ e4  f8 ) r \!
            \break
        }
    }
    
    \repeat volta 2 {
        fis8 -> -\f ^\markup { "Alarm with ending" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
    }
    \alternative {
        {
            g8 -> -. r r a8 -> -. r r fis4~ -> -\mf \< |
            fis4. e8 ( ~ e4  f8 ) r \!
        }
        {
            g8 -> -. r r a8 -> -. r r fis4 -> -. |
            r8 fis ( e d e d a ais
            \break
        }
    }
    
    b1 \> ) ^\markup { "Clave" } ~ |
    b1 \mp | 
    \set Score.skipBars = ##t R1*2
    R1 ^\markup { "Verse 1" } |
    R1 |
    R1 |
    fis8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 ~ -> \sf \< |
    ais | \break
    
    r2 \! ^\markup { "Pre-Chorus" } b'4 -> \ff r |
    R1 |
    r2 b4 -> r |
    R1 |
    R1 |
    R1 |
    fis8 -> -. \f r r fis -> -. r r fis4 \ff -> |
    R1 | \break
    
    \repeat volta 2 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            d8 -> -. \f r r e -> -. r r fis4 -> -. | \break
        }
    }
    
    s1*0 ^\markup { "Attaca" }
    \repeat volta 2 {
        fis8 -> ^\markup { "Alarm" } fis fis fis -. r2 |
        e8 -> e e e -. r2 |
    }
    \alternative {
        {
            g8 -> -. r r a8 -> -. r r fis4~ -> -\mf \< |
            fis4. e8 ( ~ e4  f8 ) r \!
        }
        {
            g8 -> -. r r a8 -> -. r r fis4 -> -. |
            r8 fis ( e d e d a ais
            \break
        }
    }
    
    b1 \> ) ^\markup { "Verse 2" } ~ |
    b1 \mp | 
    R1 |
    fis8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 ~ -> \sf \< |
    ais | \break
    
    r2 \! ^\markup { "Pre-Chorus" } b'4 -> \ff r |
    R1 |
    r2 b4 -> r |
    R1 |
    R1 |
    R1 |
    fis8 -> -. \f r r fis -> -. r r fis4 \ff -> |
    R1 | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            d8 -> -. \f r r e -> -. r r fis4 -> -. |
            R1 ^\markup { "Clave" } |
        }
    }
    
    \set Score.skipBars = ##t R1*4 ^\markup { "Piano Montuno" } \break
    
    
    R1 ^\markup { "Flute melody" } |
    R1 |
    R1 |
    fis,8 -\mp fis r a r fis ( a ) r |
    b1 -> \< ~ |
    b2. \mf r4 |
    R1 |
    cis,8 -\mp cis r e r cis ( e ) r | \break
    fis1 ^\markup { "Flute variations" } -> \mp \< ~ |
    fis2. \mf r4 |
    R1 |
    cis8 -\mp cis r e r cis ( e ) r |
    fis1 -> \mp \< ~ | 
    fis2. \mf r4 |
    ais1 -> \sf \<  |
    r \f \! ^\markup { "Sax start" } | \break

    \set Score.skipBars = ##t R1*8 ^\markup { "Sax solo (with interruptions)" } | \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Chorus (longer)" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e'8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            b8 -> -. \f r r cis -> -. r r d4 \fff -! -> |
            R1 | \break
        }
    }
    
    
    \set Score.skipBars = ##t R1* 4 ^\markup { "Pero sí no quieres ..." }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Montuno (Coro Pregón)" } \break
    
    \repeat volta 2 {
      d8 \ff -. ^\markup { "Alarm" } d -. d -. d4 -- cis8 -. cis -. cis -. |
      cis4 -- fis8 -. fis -. fis -. fis -- r fis -- |
      r fis -- r fis -- r4. fis8 -- |
      r fis -- r fis -- r2 | \break
    }
    \set Score.skipBars = ##t R1* 16 ^\markup { "Coro Pregón 2" }
    \set Score.skipBars = ##t R1* 32 ^\markup { "Este dia (sing)" } \break
    
    \repeat volta 4 {
        \set Score.skipBars = ##t R1*4 ^\markup { "Este dia + Chorus" } |
    }
    \alternative {
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r eis4 \ff \bendAfter #-8 -> |
        }
        {
            R1 |
            R1 |
            R1 |
            e8 -> -. \f r r e -> -. r r d8 -> r | \break
        }
    }
    
    \repeat volta 4 {
        d8 \ff -. ^\markup { "Alarm" } d -. d -. d4 -- cis8 -. cis -. cis -. |
    }
    \alternative {
        {
            cis4 -- fis8 -. fis -. fis -. fis -- r fis -- |
            r fis -- r fis -- r4. gis8 -- |
            r gis -- r gis -- r2 | \break
        }
        {
            cis,4 -- fis8 -. fis -. fis -. fis -. r4 |
            fis8 -. fis -. fis -. fis -. r4 fis8 -. fis -. |
            fis -. fis -.  r4 fis8 -. fis -. fis -. fis -. |
        }
    }
    R1 |
    r2. b,4 |
    
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