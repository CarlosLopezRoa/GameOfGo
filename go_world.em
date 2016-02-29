globals [
  global-temperature     
  num-blackss         
  num-whitess            
  scenario-phase        
  global-score-blacks
  global-score-whites
  blacks-pass
  whites-pass
  winner 
  ]

breed [blacks]
breed [whites]
undirected-link-breed [teams team]

patches-own [temperature]  

blacks-own [
  libertynot  
  score-blacks
  libertygroup
  explored?
]

whites-own [
  libertynot 
  score-whites
  libertygroup
  explored?
]

to setup
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
  seed-blackss-randomly
  seed-whitess-randomly
  ask patches [calc-temperature]
  set global-temperature (mean [temperature] of patches)
  update-display
  reset-ticks
end

to seed-blackss-randomly
     go_blacks
end

to seed-whitess-randomly
     go_whites
end

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
    output-print (word winner "-wins,"  num-blackss ","  num-whitess )
    stop]
end

to experiment
    if winner != nobody [setup]
    go
end

to set-as-blacks 
  set color black
  set size 0.6
  set explored? false 
  create-links-with turtles-on neighbors4 with [any? blacks-here]
  loop
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

to explore
  if explored? [stop]
  set explored? true
  ask link-neighbors [explore]
  if breed = blacks [
  create-links-with other blacks with [explored?]]
  if breed = whites [
    create-links-with other whites with [explored?]]
end


to check-survivability 
  if libertynot = 0 and libertygroup = 0
  [
  if (breed = whites)
    [ask whites [set score-whites (score-whites + count(link-neighbors) + 1) ] 
     ask link-neighbors [die]
     die]
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


to calc-temperature  
  set temperature (count(turtles-on neighbors4)) 
end

to paint-blacks   
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

to update-display
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