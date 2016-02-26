breed [cells cell]    ;; living cells
breed [babies baby]   ;; show where a cell will be born

patches-own [
  live-neighbors  ;; count of how many neighboring cells are alive
]

to setup-blank
  clear-all
  set-default-shape cells "circle"
  set-default-shape babies "dot"
  ask patches
    [ set live-neighbors 0 ]
  reset-ticks
end

to setup-random
  setup-blank
  ;; create initial babies
  ask patches
    [ if random-float 100.0 < initial-density
      [ sprout-babies 1 ] ]
  ;; grow the babies into adult cells
  go
  reset-ticks  ;; set the tick counter back to 0
end

;; this procedure is called when a cell is about to become alive
to birth  ;; patch procedure
  sprout-babies 1
  [ ;; soon-to-be-cells are lime
    set color lime + 1 ]  ;; + 1 makes the lime a bit lighter
end

to go
  ;; get rid of the dying cells from the previous tick
  ask cells with [color = gray]
    [ die ]
  ;; babies become alive
  ask babies
    [ set breed cells
      set color white ]
  ;; All the live cells count how many live neighbors they have.
  ;; Note we don't bother doing this for every patch, only for
  ;; the ones that are actually adjacent to at least one cell.
  ;; This should make the program run faster.
  ask cells
    [ ask neighbors
      [ set live-neighbors live-neighbors + 1 ] ]
  ;; Starting a new "ask" here ensures that all the cells
  ;; finish executing the first ask before any of them start executing
  ;; the second ask.
  ;; Here we handle the death rule.
  ask cells
    [ ifelse live-neighbors = 2 or live-neighbors = 3
      [ set color white ]
      [ set color gray ] ] ;; gray cells will die next round
                           ;; Now we handle the birth rule.
  ask patches
    [ if not any? cells-here and live-neighbors = 3
      [ birth ]
    ;; While we're doing "ask patches", we might as well
    ;; reset the live-neighbors counts for the next generation.
    set live-neighbors 0 ]
  tick
end

;; user adds or removes cells with the mouse
to draw-cells
  let erasing? any? cells-on patch mouse-xcor mouse-ycor
  while [mouse-down?]
    [ ask patch mouse-xcor mouse-ycor
      [ ifelse erasing?
        [ erase ]
        [ draw ] ]
    display ]
end

;; user adds a cell with the mouse
to draw  ;; patch procedure
  if not any? cells-here
    [ ask turtles-here [ die ]  ;; old cells and babies go away
      sprout-cells 1 [ set color white ]
      update
      ask neighbors [ update ] ]
end

;; user removes a cell with the mouse
to erase  ;; patch procedure
  ask turtles-here [ die ]
  update
  ask neighbors [ update ]
end

;; this isn't called from GO.  it's only used for
;; bringing individual patches up to date in response to
;; the user adding or removing cells with the mouse.
to update  ;; patch procedure
  ask babies-here
    [ die ]
  let n count cells-on neighbors
  ifelse any? cells-here
    [ ifelse n = 2 or n = 3
      [ ask cells-here [ set color white ] ]
      [ ask cells-here [ set color gray  ] ] ]
    [ if n = 3
      [ sprout-babies 1
        [ set color lime + 1 ] ] ]
  set live-neighbors 0  ;; reset for next time through "go"
end


; Copyright 2005 Uri Wilensky.
; See Info tab for full copyright and license.