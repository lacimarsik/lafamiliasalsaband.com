\version "2.22.2"

% Sheet revision 2022_09

\header {
  title = "Would I Lie"
  instrument = "timbales"
  composer = "by Cubaneros"
  arranger = "arr. Ladislav Maršík"
  opus = "version 7.9.2022"
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

Timbales = \new DrumVoice \drummode {
  \set Staff.instrumentName = \markup {
    \center-align { "Timbales" }
  }

  \time 4/4
  \tempo "Fast Salsa" 4 = 210

  R1*14 ^\markup { "A Capella" }
  
  \tuplet 3/2 { cb4 cb cb } \tuplet 3/2 { cb cb cb} | 
  timh r8 timl8 timl4 cymc -^ |
  
  \inst "A"
  \repeat percent 8 {
    r8 ^\markup { "Chorus (campana 3/2)" } cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "B"
  R1*16 ^\markup { "Verse 1 (tumbao + maracas)" } 
  
  
  hhc8-. ^\markup { "(tumbao + martillo + cascara 2-3)" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
  
  hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  r2 timh8 timh r timh |
  r timh timl timl cb -^ cb -^ r4 |
  
  \inst "C"
  \repeat percent 8 {
    r8 ^\markup { "Chorus (campana 3/2)" } cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "D"
  R1*16 ^\markup { "Verse 2 (tumbao + maracas)" } 
  
  \inst "E"
  hhc8-. ^\markup { "Swing!" } hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. hhp hhc-. |
  
  hhc-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. -. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  hhc-. hhp hhc-. hhc-. hhp hhc-. cymc4 -^ |
  
  hhc8-. hhp hhc-. hhp hhc-. hhc-. hhp hhc-. |
  timh timl r timl r timl cymc4 -^ |
  
  \repeat percent 8 {
    r8 ^\markup { "Chorus (campana 3/2)" } cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  \inst "F"
  \repeat percent 8 {
    r8 ^\markup { "Trombone solo (campana 3/2)" } cb cb cb cb r cb cb |
    cb r cb r cb cb cb cb |
  }
  
  
  rb8 -. ^\markup { "Would I lie to you (camp. + contrac.)" } ^\markup { "Timbal Solo" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
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
  
  \inst "G"
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
    rb8 -. ^\markup { "Chorus (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb cymc4 -^ |
  rb8 -. cb <<cb hhho>> timl timh timh r timl |
  r timh r timh r2 |
  
  \inst "H"
  cymc8 -^ ^\markup { "Montuno - Petas (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  \repeat percent 3 {
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  
  rb8 -. cb cymc -^ cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  \repeat percent 2 {
    rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
    <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  }
  
  rb8 -. cb <<cb hhho>> cb rb -. timh timh timh | 
  timh timh r4 r2 |
  
  \inst "I"
  cymc8 -^ ^\markup { "Coro Pregón (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  cymc8 -^ cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  timl timl cymc -^ r timl timl cymc -^ r |
  timl timl cymc -^ r timl timh timh r |
  
  cymc8 -^ ^\markup { "Fade out (camp. + contrac.)" } cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -.  cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -.  cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  rb8 -. cb <<cb hhho>> cb rb -. r <<cb hhho>> <<cb hhho>> |
  <<cb rb -.>> r <<cb hhho>> hhho rb -. cb <<cb hhho>> <<cb hhho>> |
  
  R1*8 ^\markup { "A Capella" }    
  
  \label #'lastPage
  \bar "|."
}

\score {
  \compressMMRests \new StaffGroup <<
    \new DrumStaff \with {
      drumStyleTable = #timbales-style
      \override StaffSymbol.line-count = #2
      \override BarLine.bar-extent = #'(-1 . 1)
      \consists "Volta_engraver"
    }
    <<
      \Timbales
    >>
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
  #'((basic-distance . 15)
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
      \on-the-fly #print-page-number-check-first
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
      \on-the-fly #print-page-number-check-first
      \concat { \fromproperty #'page:page-number-string "/" \page-ref #'lastPage "0" "?" }
    }
  }
}