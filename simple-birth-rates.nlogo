globals
[
  red-count            ; population of red turtles
  blue-count           ; population of blue turtles
]

turtles-own
[
  fertility            ; the whole number part of fertility
  fertility-remainder  ; the fractional part (after the decimal point)
]

to setup
  clear-output
  setup-experiment
end

to setup-experiment
  cp ct
  clear-all-plots
  reset-ticks
  crt carrying-capacity
  [
    setxy random-xcor random-ycor         ; randomize turtle locations
    ifelse who < (carrying-capacity / 2)  ; start out with equal numbers of reds and blues
      [ set color blue ]
      [ set color red ]
    set size 2                            ; easier to see
  ]
  reset-ticks
end

to go
  reproduce
  grim-reaper
  tick
end

;; to enable many repetitions with same settings
to go-experiment
  go
  if red-count = 0
  [
    output-print (word "red extinct after " ticks " generations")
    setup-experiment
  ]
  if blue-count = 0
  [
    output-print (word "blue extinct after " ticks " generations")
    setup-experiment
  ]
end

to wander  ;; turtle procedure
  rt random-float 30 - random-float 30
  fd 1
end

to reproduce
  ask turtles
  [
    ifelse color = red
    [
      set fertility floor red-fertility
      set fertility-remainder red-fertility - (floor red-fertility)
    ]
    [
      set fertility floor blue-fertility
      set fertility-remainder blue-fertility - (floor blue-fertility)
    ]
    ifelse (random-float 100) < (100 * fertility-remainder)
      [ hatch fertility + 1 [ wander ]]
      [ hatch fertility     [ wander ]]
  ]
end

;; kill turtles in excess of carrying capacity
;; note that reds and blues have equal probability of dying
to grim-reaper
  let num-turtles count turtles
  if num-turtles <= carrying-capacity
    [ stop ]
  let chance-to-die (num-turtles - carrying-capacity) / num-turtles
  ask turtles
  [
    if random-float 1.0 < chance-to-die
      [ die ]
  ]
end


; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.