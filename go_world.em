globals [
;  max-age               ;; maximum age that all blacks live to
  global-temperature    ;; the average temperature of the patches in the world
  num-blackss            ;; the number of blacks blacks
  num-whitess            ;; the number of whites blacks
  scenario-phase        ;; interval counter used to keep track of what portion of scenario is currently occurring
  global-score-blacks
  global-score-whites
  blacks-pass
  whites-pass
  winner 
  ]

breed [blacks]
breed [whites]
undirected-link-breed [teams team]

patches-own [temperature
;  score-blacks
;  score-whites
]  ;; local temperature at this location

blacks-own [
;  age       ;; age of the whites
;  albedo    ;; fraction (0-1) of energy absorbed as heat from sunlight
  libertynot   ;; free liberties
  score-blacks
  libertygroup
  explored?
]

whites-own [
;  age       ;; age of the whites
;  albedo    ;; fraction (0-1) of energy absorbed as heat from sunlight
  libertynot   ;; free liberties
  score-whites
  libertygroup
  explored?
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  set-default-shape blacks "flower"
  set-default-shape whites "flower"
  ask patches [ set pcolor gray ]

;  set max-age 25
  set winner nobody
  set global-temperature 0
  ask blacks [set score-blacks 0]
  ask whites [set score-whites 0]
  set blacks-pass false
  set whites-pass false
;  if (scenario = "ramp-up-ramp-down"    ) [ set solar-luminosity 0.8 ]
;  if (scenario = "low solar luminosity" ) [ set solar-luminosity 0.6 ]
;  if (scenario = "our solar luminosity" ) [ set solar-luminosity 1.0 ]
;  if (scenario = "high solar luminosity") [ set solar-luminosity 1.4 ]
  seed-blackss-randomly
  seed-whitess-randomly
;  ask blacks [go_blacks]
;  ask whites [go_whites]
;  ask blacks [set age random max-age]
  ask patches [calc-temperature]
  set global-temperature (mean [temperature] of patches)
  update-display
  reset-ticks
end

to seed-blackss-randomly
   ;ask n-of 1 patches with [not any? blacks-here and not any? whites-here]
    ; [ sprout-blacks 1 [set-as-blacks] ]
     go_blacks
end

to seed-whitess-randomly
   ;ask n-of 1 patches with [not any? blacks-here and not any? whites-here]
    ; [ sprout-whites 1 [set-as-whites] ]
     go_whites
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Procedures ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to go
  ifelse not blacks-pass or  not whites-pass 
  [
   ask patches [calc-temperature]
   diffuse temperature .5
   go_blacks
   ask whites [check-survivability]
   go_whites
   ask blacks [check-survivability]
   if (num-whitess = 0 or num-blackss = 0 ) [stop]
   ask links [set hidden? true]
   set global-temperature (sum [temperature] of patches)
   set global-score-blacks (max [score-blacks] of blacks ) 
   set global-score-whites (max [score-whites] of whites )
   ask blacks [set score-blacks max [score-blacks] of blacks]
   ask whites [set score-whites max [score-whites] of whites]
   update-display
   tick
  ]
  [ if num-blackss > num-whitess
    [set winner "Blacks"]
    if num-blackss < num-whitess
    [set winner "Whites"]
    if num-blackss = num-whitess
    [set winner "Tie"]
    output-print (word winner "  wins")
    stop]
 ;  if (scenario = "ramp-up-ramp-down")
 ;  [
 ;    if (ticks > 200 and ticks <= 400) [set solar-luminosity solar-luminosity + 0.005]
 ;    if (ticks > 600 and ticks <= 850) [set solar-luminosity solar-luminosity - 0.0025]
; ]
;   if (scenario = "low solar luminosity")  [set solar-luminosity 0.6 ]
;   if (scenario = "our solar luminosity")  [set solar-luminosity 1.0 ]
;   if (scenario = "high solar luminosity") [set solar-luminosity 1.4 ]
end

to experiment
    if winner != nobody [setup]
    go
end

to set-as-blacks ;; turtle procedure
  set color black
;  set albedo albedo-of-blackss
;  set age 0
  set size 0.6
  set explored? false 
  create-links-with turtles-on neighbors4 with [any? blacks-here]
  loop
  [ let start one-of blacks with [not explored?]
    if start = nobody [stop]
    ask start [explore]
    ;ask start [set explored? false]
    ask blacks [ set explored? false ]
    stop
  ]
end

to set-as-whites  ;; turtle procedure
  set color white
;  set albedo albedo-of-whitess
;  set age 0
  set size 0.6
  set explored? false 
  create-links-with turtles-on neighbors4 with [any? whites-here]
  loop
  [ let start one-of whites with [not explored?]
    if start = nobody [stop]
    ask start [explore]
    ;ask start [set explored? false]
    ask whites [ set explored? false ]
    stop
  ]
end

to explore
  if explored? [stop]
  set explored? true
  ask link-neighbors [explore]
  if breed = blacks [
  create-links-with other blacks with [explored?]]
  if breed = whites [
    create-links-with other whites with [explored?]]
end


to check-survivability ;; turtle procedure
;  let seed-threshold 0
;  let not-empty-spaces nobody
;  let seeding-place nobody
;if breed = whites [ ]
;if breed = blacks [ ]
 ; set age (age + 1)
  if ;1 = 0;
  libertynot = 0 and libertygroup = 0
  ;[
  ;   set seed-threshold (-(temperature - 2) ^ 2 + 1 );((0.1457 * temperature) - (0.0032 * (temperature ^ 2)) - (0.6443))
     ;; This equation may look complex, but it is just a parabola.
     ;; This parabola has a peak value of 1 -- the maximum growth factor possible at an optimum
     ;; temperature of 22.5 degrees C
     ;; -- and drops to zero at local temperatures of 5 degrees C and 40 degrees C. [the x-intercepts]
     ;; Thus, growth of new blacks can only occur within this temperature range,
     ;; with decreasing probability of growth new blacks closer to the x-intercepts of the parabolas
     ;; remember, however, that this probability calculation is based on the local temperature.
     
   ;  if (random 1.0 < seed-threshold) [
   ;    set seeding-place one-of patches with [not any? blacks-here and not any? whites-here]

    ;   if (seeding-place != nobody)
    ;   [
     ;    if (color = white)
     ;    [
     ;      ask seeding-place [sprout-whites 1 [set-as-whites]  ]
     ;    ]
     ;    if (color = black)
     ;    [
     ;      ask seeding-place [sprout-blacks 1 [set-as-blacks]  ]
      ;   ]
      ; ]
    ; ]
  ;]
  [
  if (breed = whites)
  ;[ ask whites [set score-whites (score-whites + 
   ;     1) ]
        ;count(whites with [libertynot >= count(turtles-on neighbors4 with [any? blacks-here])]))
   ; ask whites with [libertynot >= count(turtles-on neighbors4 with [any? blacks-here])] 
    [ask whites [set score-whites (score-whites + count(link-neighbors) + 1) ] 
     ask link-neighbors [die]
     die]
  ;]
  if (breed = blacks)
  ;[ ask blacks [set score-blacks (score-blacks + 
        ;1 ) ]
  
        ;count( blacks with [libertynot >= count(turtles-on neighbors4 with [any? whites-here])])) ]
   ; ask blacks with [libertynot >= count(turtles-on neighbors4 with [any? whites-here])] 
    [ask blacks [set score-blacks (score-blacks + count(link-neighbors) + 1) ]
      ask link-neighbors [die]
      die]
  ;ask blacks [set score-whites (score-whites + 1)]
  ;]

  ]
end

to go_blacks
  set blacks-pass false
  ifelse count (patches with [not any? whites-here  and not any?  blacks-here
    and ((count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4) ))
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    ]) != 0
  [
  ask n-of 1 patches with [not any? whites-here  and not any?  blacks-here
    and (count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4))
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    ]
     [ sprout-blacks 1 [set-as-blacks] ]
  ]
  [set blacks-pass true
  ]
   ask blacks [set libertynot count(neighbors4) - count(turtles-on neighbors4)
   set libertygroup (sum [libertynot] of link-neighbors + libertynot)]
end

to go_whites
  set whites-pass false
  ifelse count (patches with [not any? blacks-here and not any? whites-here
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    and (count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4))
    ]) != 0
    [
  ask n-of 1 patches with [not any? blacks-here and not any? whites-here
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    and (count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4))
    ]
     [ sprout-whites 1 [set-as-whites] ]
    ]
   [set whites-pass true]
   ask whites [set libertynot count(neighbors4) - count(turtles-on neighbors4)
   set libertygroup (sum [libertynot] of link-neighbors + libertynot)]
end


to calc-temperature  ;; patch procedure
 ; let absorbed-luminosity 0
 ; let local-heating 0
 ; ifelse not any? blacks-here
  ;[   ;; the percentage of absorbed energy is calculated (1 - albedo-of-surface) and then multiplied by the solar-luminosity
      ;; to give a scaled absorbed-luminosity.
   ; set absorbed-luminosity ((1 - albedo-of-surface) * solar-luminosity)
  ;]
  ;[
      ;; the percentage of absorbed energy is calculated (1 - albedo) and then multiplied by the solar-luminosity
      ;; to give a scaled absorbed-luminosity.
  ;  ask one-of blacks-here
   ;   [set absorbed-luminosity ((1 - albedo) * solar-luminosity)]
  ;]
  ;; local-heating is calculated as logarithmic function of solar-luminosity
  ;; where a absorbed-luminosity of 1 yields a local-heating of 80 degrees C
  ;; and an absorbed-luminosity of .5 yields a local-heating of approximately 30 C
  ;; and a absorbed-luminosity of 0.01 yields a local-heating of approximately -273 C
  ;ifelse absorbed-luminosity > 0
   ;   [set local-heating 72 * LN(absorbed-luminosity) + 80]
    ;  [set local-heating 80]
  set temperature (count(turtles-on neighbors4)) ;with [not any? blacks-here]);((temperature + local-heating) / 2)
     ;; set the temperature at this patch to be the average of the current temperature and the local-heating effect
end

to paint-blacks   ;; whites painting procedure which uses the mouse location draw blacks when the mouse button is down
  if mouse-down?
  [
    ask patch mouse-xcor mouse-ycor [
      ifelse not any? blacks-here
      [
        if paint-blacks-as = "add black"
          [sprout-blacks 1 [set-as-blacks]]
        if paint-blacks-as = "add white"
          [sprout-whites 1 [set-as-whites]]
      ]
      [
        if paint-blacks-as = "remove"
          [ask blacks-here [die]]
      ]
      display  ;; update view
    ]
  ]
end

to update-display
  ifelse (show-temp-map? = true)
    [ ask patches [set pcolor scale-color brown temperature -7 7] ]  ;; scale color of patches to the local temperature
    [ ask patches [set pcolor grey] ]

  ifelse (show-blacks? = true)
    [ ask blacks [set hidden? false] ]
    [ ask blacks [set hidden? true] ]
end


; Copyright 2006 Uri Wilensky.
; See Info tab for full copyright and license.