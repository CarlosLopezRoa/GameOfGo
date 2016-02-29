globals [
  global-temperature        ;Shown as capacity of the world
  num-blackss               ;number of black stones plus captured white stones
  num-whitess               ;number of white stones plus captured black stones
  scenario-phase            
  global-score-blacks       ;max of individual stored captured blacks
  global-score-whites       ;max of individual stored captured whites
  blacks-pass               ;Boolean, has blacks passed?
  whites-pass               ;Boolean, has whites passed?
  winner                    ;String, Who is the winner?
  ]

breed [blacks]    ;Two breeds
breed [whites]
undirected-link-breed [teams team] ;Undirected links

patches-own [temperature]   ;Liberty of the patch

blacks-own [      ;Internal variables of stones
  libertynot      ;The liberty of the stone
  score-blacks    ;Internal score of blacks captured
  libertygroup    ;The liberty of the group
  explored?       ;Bolean, is he explored in recursive search
]

whites-own [
  libertynot 
  score-whites
  libertygroup
  explored?
]

to setup   ;Set variables
  clear-all
  set-default-shape blacks "flower"
  set-default-shape whites "flower"
  ask patches [ set pcolor gray ]
  set winner nobody
  set global-temperature 0
  ask blacks [set score-blacks 0]
  ask whites [set score-whites 0]
  set blacks-pass false
  set whites-pass false
  seed-blackss-randomly  ;Initiallize two stones 
  seed-whitess-randomly
  ask patches [calc-temperature]
  set global-temperature (mean [temperature] of patches)
  update-display
  reset-ticks
end

to seed-blackss-randomly  ;It was necessary to use a observer procedure to call a turtle procedure
     go_blacks
end

to seed-whitess-randomly
     go_whites
end

to go  ;Turtle procedure, To go
  ifelse not blacks-pass or  not whites-pass ;Main IF, has both passed sucesively?
  [
   ask patches [calc-temperature] ;Update patch color
   diffuse temperature .5
   go_blacks                         
   ask whites [check-survivability]
   go_whites
   ask blacks [check-survivability]
   if (num-whitess = 0 or num-blackss = 0 ) [stop] 
   set global-temperature (sum [temperature] of patches) ;update global variables
   set global-score-blacks (max [score-blacks] of blacks ) 
   set global-score-whites (max [score-whites] of whites )
   ask blacks [set score-blacks max [score-blacks] of blacks]
   ask whites [set score-whites max [score-whites] of whites]
   update-display
   tick
  ]
  [ if num-blackss > num-whitess  ;Determine winner
    [set winner "Blacks"]
    if num-blackss < num-whitess
    [set winner "Whites"]
    if num-blackss = num-whitess
    [set winner "Tie"]
    output-print (word winner "-wins,"  num-blackss ","  num-whitess ) ;Print Winner
    stop]
end

to experiment  ; Experimentation procedure, to keep creating games
    if winner != nobody [setup]
    go
end

to set-as-blacks  
  set color black 
  set size 0.6
  set explored? false 
  create-links-with turtles-on neighbors4 with [any? blacks-here] ;make group with neighbors
  loop    ;Recursively make group with the neighbors of neighbors 
  [ let start one-of blacks with [not explored?]  
    if start = nobody [stop]
    ask start [explore]
    ask blacks [ set explored? false ]
    stop
  ]
end

to set-as-whites  
  set color white
  set size 0.6
  set explored? false 
  create-links-with turtles-on neighbors4 with [any? whites-here]
  loop
  [ let start one-of whites with [not explored?]
    if start = nobody [stop]
    ask start [explore]
    ask whites [ set explored? false ]
    stop
  ]
end

to explore ;Recursively set explored
  if explored? [stop]
  set explored? true
  ask link-neighbors [explore]
  if breed = blacks [
  create-links-with other blacks with [explored?]]
  if breed = whites [
  create-links-with other whites with [explored?]]
end


to check-survivability   ;Kill if no liberties 
  if libertynot = 0 and libertygroup = 0
  [
  if (breed = whites)  
    [ask whites [set score-whites (score-whites + count(link-neighbors) + 1) ] ;Give the score to the other player
     ask link-neighbors [die] ;Ask all members of the group to die
     die] ;Before dying
  if (breed = blacks)
    [ask blacks [set score-blacks (score-blacks + count(link-neighbors) + 1) ]
      ask link-neighbors [die]
      die]
  ]
end

to go_blacks
  set blacks-pass false  
  ifelse count (patches with [not any? whites-here  and not any?  blacks-here  
    and ((count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4) ))
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    ]) != 0 ;Are there any patches to put stones?
  [
  ask n-of 1 patches with [not any? whites-here  and not any?  blacks-here
    and (count (turtles-on neighbors4 with [any? whites-here]) < count(neighbors4))
    and (count (turtles-on neighbors4 with [any? blacks-here]) < count(neighbors4))
    ] ;Pick one
     [ sprout-blacks 1 [set-as-blacks] ] ; Create one turtle there
  ]
  [set blacks-pass true
  ]
   ask blacks [set libertynot count(neighbors4) - count(turtles-on neighbors4) ;Set individual liberty
   set libertygroup (sum [libertynot] of link-neighbors + libertynot)] ;Set group liberty
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


to calc-temperature  
  set temperature (count(turtles-on neighbors4)) ;The liberty of a patch
end

to paint-blacks    ;Manual input of stones
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
      display  
    ]
  ]
end

to update-display  ;Plotting options
  ifelse (show-temp-map? = true)
    [ ask patches [set pcolor scale-color brown temperature -7 7] ]  
    [ ask patches [set pcolor grey] ]

  ifelse (show-blacks? = true)
    [ ask blacks [set hidden? false] ]
    [ ask blacks [set hidden? true] ]
    
  ifelse (show-connections? = true)
   [ ask links [set hidden? false] ]
    [ ask links [set hidden? true] ]
end