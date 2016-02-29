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
@#$#@#$#@
GRAPHICS-WINDOW
424
10
934
541
-1
-1
25.0
1
10
1
1
1
0
0
0
1
0
19
0
19
1
1
1
ticks
30.0

SWITCH
14
306
164
339
show-temp-map?
show-temp-map?
0
1
-1000

BUTTON
6
45
71
78
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
6
8
71
41
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
14
264
164
297
show-blacks?
show-blacks?
0
1
-1000

PLOT
220
13
420
163
Capacity
NIL
NIL
0.0
100.0
0.0
4.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot global-temperature"

PLOT
220
305
420
540
Score
NIL
NIL
0.0
100.0
0.0
100.0
true
false
"" "set num-whitess (count turtles with [color = white] + global-score-blacks)\nset num-blackss (count turtles with [color = black] + global-score-whites)"
PENS
"blacks" 1.0 0 -16777216 true "" "plot (num-blackss)"
"whites" 1.0 0 -7500403 true "" "plot (num-whitess)"

BUTTON
8
141
143
184
Put manually
paint-blacks
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
12
199
148
244
paint-blacks-as
paint-blacks-as
"add black" "add white" "remove"
1

BUTTON
7
93
94
126
Go 4ever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
107
93
209
126
Experiment
experiment
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
16
355
194
388
show-connections?
show-connections?
0
1
-1000

@#$#@#$#@
## WHAT IS IT?


## HOW IT WORKS



## HOW TO USE IT


## THINGS TO NOTICE



## THINGS TO TRY


## EXTENDING THE MODEL



## NETLOGO FEATURES


## RELATED MODELS


## CREDITS AND REFERENCES



## HOW TO CITE



## COPYRIGHT AND LICENSE
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
true
0
Circle -7500403 true true 30 30 240
Circle -7500403 true true 0 120 60
Circle -7500403 true true 240 120 60
Circle -7500403 true true 120 0 60
Circle -7500403 true true 120 240 60
Circle -7500403 true true 60 225 60
Circle -7500403 true true 180 225 60
Circle -7500403 true true 225 180 60
Circle -7500403 true true 15 180 60
Circle -7500403 true true 15 60 60
Circle -7500403 true true 225 60 60
Circle -7500403 true true 180 15 60
Circle -7500403 true true 60 15 60

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
