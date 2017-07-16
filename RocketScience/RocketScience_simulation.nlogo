globals [
  total-amount-of-students
  total-amount-of-students_at_erba
  
  students_at_cafeteria
  students_at_library
  
  is_break
  timer_counter

  ;global strings
  s_room_type_entrance
  s_room_type_lecture
  s_room_type_sitting
  s_room_type_arrival

  s_room_area_in
  s_room_area_out

  s_room_level_ground
  s_room_level_upstairs

  s_file_rooms
  s_file_timetables
  s_file_courses

  s_stud_phone_iphone
  s_stud_phone_android
  s_stud_phone_none

  weekday
  time
  timerCount
  counter
  is-break
  pause

  cafeteria_beacon
  cafeteria_beacons_total_count
  cafeteria_beacons_detections_total_count
  current_cafeteria_beacon_interactions

  entrance_foyer_beacon
  entrance_foyer_beacons_total_count
  entrance_foyer_beacons_detections_total_count
  current_entrance_foyer_beacon_interactions

  entrance_seminar_beacon
  entrance_seminar_beacons_total_count
  entrance_seminar_beacons_detections_total_count
  current_entrance_seminar_beacon_interactions

  lecture_hall_right_beacon
  lecture_hall_right_beacons_total_count
  lecture_hall_right_beacons_detections_total_count
  current_lecture_hall_right_beacon_interactions
]

breed [rooms room]
breed [students student]
breed [courses course]
breed [timetables timetable]

rooms-own [
  room_name
  room_type ;values: "entrance", "lecture", "sitting" or "arrival"
  room_area ;values: "in" or "out"
  room_level ;values: "ground" or "upstairs"
]

students-own [
  stud_target
  stud_home_target
  stud_tmp_target
  stud_current_location
  stud_timetable
  stud_courrent_course
  stud_beacon_interaction
  stud_phone
  stud_phone_can_detect_beacons
  stud_phone_bluetooth_always_active
  stud_phone_is_scanning
]

courses-own [
  course_id
  course_name
  course_location
  course_type
  course_room
  course_day
  course_startTime
  course_endTime
  course_participants
]

timetables-own [
  table
]


to setup
  clear-all
  reset-ticks
  import-drawing "erba.jpg"
  setup-variables
  setup-courses
  setup-timetables
  setup-rooms
  setup-students
end


to setup-variables
  set total-amount-of-students students_at_erba
  set total-amount-of-students_at_erba 0
  
  set students_at_cafeteria 0
  set students_at_library 0

  set s_room_type_entrance "entrance"
  set s_room_type_lecture "lecture"
  set s_room_type_sitting "sitting"
  set s_room_type_arrival "arrival"

  set s_room_area_in "in"
  set s_room_area_out "out"

  set s_room_level_ground "ground"
  set s_room_level_upstairs "upstairs"

  set s_file_rooms "rooms_rocket_science.txt"
  set s_file_timetables "timetables_rocket_science.txt"
  set s_file_courses "courses_rocket_science_new.txt"

  set s_stud_phone_iphone "iphone"
  set s_stud_phone_android "android"
  set s_stud_phone_none "none"

  set weekday 1
  set is-break true
  set counter 75; initial starttime to get to the first time slot
  set pause "pause"

  set cafeteria_beacon "cafeteria-beacon"
  set entrance_foyer_beacon "foyer-entrance-beacon"
  set entrance_seminar_beacon "seminar-entrance-beacon"
  set lecture_hall_right_beacon "lecture-hall-right-beacon"

end

to setup-courses
  file-open s_file_courses
  while [ not file-at-end? ] [
    let tmp_id file-read
    let tmp_name file-read
    let tmp_location file-read
    let tmp_type file-read
    let tmp_room file-read
    let tmp_day file-read
    let tmp_startTime file-read
    let tmp_endTimfe file-read
    let tmp_participants file-read
    if tmp_location = "erba" [
      create-courses 1 [
        set course_id tmp_id
        set course_name tmp_name
        set course_location tmp_location
        set course_type tmp_type
        set course_room tmp_room
        set course_day tmp_day
        set course_startTime tmp_startTime
        set course_endTime tmp_startTime
        set course_participants tmp_participants
        set size 0
      ]
    ]
  ]
  file-close
end

to setup-timetables
  file-open s_file_timetables
  while [ not file-at-end? ] [
    create-timetables 1 [
      set table list (file-read) (file-read)
      repeat 8 [ set table lput file-read table]
      set size 0
    ]
  ]
  file-close
end

to setup-rooms
  file-open s_file_rooms
  while [ not file-at-end? ] [
    create-rooms 1 [
      set room_name file-read
      set room_type file-read
      set room_area file-read
      set room_level file-read
      set xcor file-read
      set ycor file-read
      set size 1
      set shape "circle"
      if room_type = s_room_type_entrance [
        set color red
      ]
      if room_type = s_room_type_lecture [
        set color green
      ]
      if room_type = s_room_type_sitting [
        set color blue
      ]
      if room_type = s_room_type_arrival [
        set color yellow
      ]
    ]
  ]
  file-close
end

to setup-students
  create-students total-amount-of-students [
    set stud_target one-of rooms with [room_type = s_room_type_arrival]
    set stud_current_location stud_target
    set stud_home_target stud_target
    set stud_timetable [table] of one-of timetables
    set stud_courrent_course but-first stud_timetable
    set stud_beacon_interaction "none"
    let phone_prob random 100
    if phone_prob <= android_share [
      set stud_phone s_stud_phone_android
    ]
    ifelse phone_prob <= (android_share + iphone_share) [
      set stud_phone s_stud_phone_iphone
    ][
      set stud_phone s_stud_phone_none
    ]
    set stud_phone_can_detect_beacons false
    let compatible_prob random 100
    if stud_phone = s_stud_phone_android [
      if compatible_prob <= nearby_compatible [
        set stud_phone_can_detect_beacons true
      ]
    ]
    if stud_phone = s_stud_phone_iphone [
      if compatible_prob <= iphone_with_physical_web_app [
        set stud_phone_can_detect_beacons true
      ]
    ]
    let bluetooth_prob random 100
    ifelse bluetooth_prob <= bluetooth_always_active [
      set stud_phone_bluetooth_always_active true
    ][
      set stud_phone_bluetooth_always_active false
    ]
    set color black
    set shape "person"
    set size 1
  ]
  ask students [
    move-to stud_home_target
  ]
end

to go
  if timerCount = 795 [ ;day is over -> start new day
    set timerCount 0 ;set time back to 7am
    set counter 75 ;initial starttime to get to the first time slot
    set time 8
    ifelse (weekday < 5) [set weekday weekday + 1] ;increase weekday
    [set weekday 1]
  ]
  
  let stud_count 0
  let stud_at_cafeteria_count 0
  let stud_at_library_count 0
  ask students [
    if stud_current_location != stud_home_target [set stud_count stud_count + 1]
    if (stud_current_location = one-of rooms with [room_name = "cafeteria"]) [set stud_at_cafeteria_count stud_at_cafeteria_count + 1]
    if (stud_current_location = one-of rooms with [room_name = "library"]) [set stud_at_library_count stud_at_library_count + 1]
  ]
  set total-amount-of-students_at_erba stud_count
  set students_at_cafeteria stud_at_cafeteria_count
  set students_at_library stud_at_library_count

  if (timerCount = counter and is-break = true) [
    set counter counter + 90 ;90 min for one time-slot
    set is-break false
  ]

  if (is-break = true) [
    move-to-target ;only move during breaks
  ]

  if (timerCount = counter and is-break = false) [
    set is-break true ;after the time slot of 90 min is over it's break time
    set time time + 2
    set counter counter + 30 ;30 min break

    ifelse (timerCount = 765) [
      ask students [
        ifelse ([room_area] of stud_current_location) != s_room_area_out [
          set stud_tmp_target stud_home_target
          set stud_target one-of rooms with [room_type = s_room_type_entrance]
        ][
          set stud_target stud_home_target
        ]
        set stud_timetable [table] of one-of timetables
      ]
    ]
    [set-target]
  ]
  tick
  set timercount timercount + 1
end

to set-target
  let actual_students_at_erba 0
  let actual_course_rooms list "" ""
  let actual_course_participants list 0 0
  
  ask courses with [course_day = weekday and course_startTime = time] [
    if course_participants != 0 and course_room != "" [
      set actual_students_at_erba actual_students_at_erba + course_participants
      set actual_course_rooms fput course_room actual_course_rooms
      set actual_course_participants fput course_participants actual_course_participants 
    ]
  ]
  let aditional_students actual_students_at_erba * aditional_percentage_of_students_per_timeslot / 100
  let aditional_students_count 1
  let tmp_participants_count 1
  let tmp_room item 0 actual_course_rooms
  let tmp_participants item 0 actual_course_participants
  set tmp_participants (tmp_participants * (100 - skip_lecture_probability) / 100)
  
  ask students [
   ifelse stud_current_location = stud_home_target [
     ;show tmp_room
     ifelse tmp_room != "" [
       ifelse tmp_participants_count <= tmp_participants [
         set stud_target one-of rooms with [room_name = tmp_room]
         set tmp_participants_count tmp_participants_count + 1
       ] [
         set tmp_participants_count 1
         set actual_course_rooms but-first actual_course_rooms
         set actual_course_participants but-first actual_course_participants
         set tmp_room item 0 actual_course_rooms
         set tmp_participants item 0 actual_course_participants
       ]
     ][
       if aditional_students >= aditional_students_count [
         set stud_target one-of rooms with [room_type = s_room_type_sitting]
         set aditional_students_count aditional_students_count + 1
       ]
     ]
   ][
     let tmp_random random 100
     ifelse tmp_random <= leave_or_sit_probability [
       set stud_target one-of rooms with [room_type = s_room_type_sitting]
     ][
       set stud_target stud_home_target
     ]
   ]
   if (stud_target != pause and stud_target != NOBODY) [
     if ([room_area] of stud_current_location) != ([room_area] of stud_target) [
       set stud_tmp_target stud_target
       set stud_target one-of rooms with [room_type = s_room_type_entrance]
     ]  
   ]
   ;setup phone
   if stud_current_location != stud_home_target or stud_target != stud_home_target [
     set stud_phone_is_scanning false
     if stud_phone != s_stud_phone_none [
       if stud_phone_can_detect_beacons [
         ifelse stud_phone_bluetooth_always_active [
           set stud_phone_is_scanning true
         ][
           let scanning_prob random 100
           if scanning_prob <= bluetooth_probability_if_not_always_active [
             set stud_phone_is_scanning true  
           ]
         ]  
       ]
     ]
   ] 
  ]
end


to move-to-target
  ask students [
    if (stud_target != pause and stud_target != NOBODY) [
      face stud_target
      ifelse distance stud_target < 1 [
        move-to stud_target
        set stud_current_location stud_target
        ifelse ([room_type] of stud_current_location) = s_room_type_entrance [
          set stud_target stud_tmp_target
          set stud_tmp_target ""
        ][
          set stud_target pause
        ]
      ]
      [
        fd 1
        if stud_beacon_interaction = cafeteria_beacon [
          set current_cafeteria_beacon_interactions  current_cafeteria_beacon_interactions - 1
          set stud_beacon_interaction "none"]
        if stud_beacon_interaction = entrance_foyer_beacon [
          set current_entrance_foyer_beacon_interactions  current_entrance_foyer_beacon_interactions - 1
          set stud_beacon_interaction "none"]
        if stud_beacon_interaction = entrance_seminar_beacon [
          set current_entrance_seminar_beacon_interactions  current_entrance_seminar_beacon_interactions - 1
          set stud_beacon_interaction "none"]
        if stud_beacon_interaction = lecture_hall_right_beacon [
          set current_lecture_hall_right_beacon_interactions  current_lecture_hall_right_beacon_interactions - 1
          set stud_beacon_interaction "none"]
      ]
      check-beacon
    ]
  ]
end

to check-beacon; student procedure
  if any? rooms with [room_name = "cafeteria" and (abs (ycor - [ ycor ] of myself) = 0) and (abs (xcor - [ xcor ] of myself) = 0) ] and stud_beacon_interaction != cafeteria_beacon
  [if stud_phone_is_scanning[
    set cafeteria_beacons_detections_total_count cafeteria_beacons_detections_total_count + 1

    let temp_prob 0
    ifelse stud_target = "pause" [
      set temp_prob cafeteria_interaction_probability]
    [set temp_prob walking_interaction_probability]
    if random 100 < temp_prob [
      set stud_beacon_interaction cafeteria_beacon
      set cafeteria_beacons_total_count cafeteria_beacons_total_count + 1
      set current_cafeteria_beacon_interactions  current_cafeteria_beacon_interactions + 1
    ]
    ]
  ]
  if any? rooms with [room_name = "entrance_foyer" and (abs (ycor - [ ycor ] of myself) = 0) and (abs (xcor - [ xcor ] of myself) = 0) ] and stud_beacon_interaction != entrance_foyer_beacon
  [if stud_phone_is_scanning[
    set entrance_foyer_beacons_detections_total_count entrance_foyer_beacons_detections_total_count + 1

   let temp_prob walking_interaction_probability
    if random 100 < temp_prob [
      set stud_beacon_interaction entrance_foyer_beacon
      set entrance_foyer_beacons_total_count entrance_foyer_beacons_total_count + 1
      set current_entrance_foyer_beacon_interactions  current_entrance_foyer_beacon_interactions + 1
    ]
    ]
  ]
  if any? rooms with [room_name = "entrance_seminar" and (abs (ycor - [ ycor ] of myself) = 0) and (abs (xcor - [ xcor ] of myself) = 0) ] and stud_beacon_interaction != entrance_seminar_beacon
  [if stud_phone_is_scanning[
    set entrance_seminar_beacons_detections_total_count entrance_seminar_beacons_detections_total_count + 1

    let temp_prob walking_interaction_probability
    if random 100 < temp_prob [
      set stud_beacon_interaction entrance_seminar_beacon
      set entrance_seminar_beacons_total_count entrance_seminar_beacons_total_count + 1
      set current_entrance_seminar_beacon_interactions  current_entrance_seminar_beacon_interactions + 1
    ]
    ]
  ]
  if any? rooms with [room_name = "lecture_big" and (abs (ycor - [ ycor ] of myself) = 0) and (abs (xcor - [ xcor ] of myself) = 0) ] and stud_beacon_interaction != lecture_hall_right_beacon
  [if stud_phone_is_scanning[
    set lecture_hall_right_beacons_detections_total_count lecture_hall_right_beacons_detections_total_count + 1

    let temp_prob 0
    ifelse stud_target = "pause" [
      set temp_prob lecture_room_interaction_probability]
    [set temp_prob walking_interaction_probability]
    if random 100 < temp_prob [
      set stud_beacon_interaction lecture_hall_right_beacon
      set lecture_hall_right_beacons_total_count lecture_hall_right_beacons_total_count + 1
      set current_lecture_hall_right_beacon_interactions  current_lecture_hall_right_beacon_interactions + 1
    ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
51
73
117
106
setup
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

BUTTON
51
119
114
152
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
59
342
209
426
Color explanation:\n\nyellow -> arrival\nred -> entrance\nblue -> sitting\ngreen -> lecture
11
0.0
1

MONITOR
57
181
120
226
weekday
weekday
0
1
11

MONITOR
131
182
188
227
time
7 + (timerCount / 60)
2
1
11

TEXTBOX
59
244
209
314
1 Monday\n2 Tuesday\n3 Wednesday\n4 Thursday\n5 Friday
11
0.0
1

MONITOR
1342
17
1545
62
Cafeteria: Total Interactions
cafeteria_beacons_total_count
17
1
11

SLIDER
690
265
911
298
technical_detection_probability
technical_detection_probability
0
100
<<<<<<< HEAD
0
=======
80.0
>>>>>>> e6769f70ddbde24973a0f13bc0328195ba6c17a1
1
1
NIL
HORIZONTAL

MONITOR
672
10
778
55
Students at Erba
total-amount-of-students_at_erba
17
1
11

MONITOR
878
14
1107
59
Cafeteria: Current Beacon Interactions
current_cafeteria_beacon_interactions
17
1
11

MONITOR
877
68
1143
113
 Entrance Foyer: Current Beacon Interactions
current_entrance_foyer_beacon_interactions
17
1
11

MONITOR
1342
71
1546
116
Entrance Foyer: Total Interactions
entrance_foyer_beacons_total_count
17
1
11

MONITOR
860
125
1139
170
Seminar Entrance: Currrent Beacon Interactions
current_entrance_seminar_beacon_interactions
17
1
11

MONITOR
1344
127
1546
172
Seminar Entrance: Total Interactions
entrance_seminar_beacons_total_count
17
1
11

MONITOR
1345
189
1548
234
Lecture Hall Right: Total interactions
lecture_hall_right_beacons_total_count
17
1
11

MONITOR
865
187
1139
232
Lecture Hall Right: Current Beacon Interactions
current_lecture_hall_right_beacon_interactions
17
1
11

SLIDER
694
315
914
348
walking_interaction_probability
walking_interaction_probability
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
1162
17
1320
62
Cafeteria Total Detections
cafeteria_beacons_detections_total_count
17
1
11

MONITOR
1147
70
1339
115
Entrance Foyer Total Detections
entrance_foyer_beacons_detections_total_count
17
1
11

MONITOR
1140
126
1343
171
Seminar Entrance Total Detections
entrance_seminar_beacons_detections_total_count
17
1
11

MONITOR
1141
188
1344
233
Lecture Hall Right Total Detections
lecture_hall_right_beacons_detections_total_count
17
1
11

SLIDER
694
381
866
414
android_share
android_share
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
695
425
867
458
iphone_share
iphone_share
0
100
17.0
1
1
NIL
HORIZONTAL

SLIDER
893
381
1065
414
nearby_compatible
nearby_compatible
0
100
71.0
1
1
NIL
HORIZONTAL

SLIDER
1151
409
1339
442
bluetooth_always_active
bluetooth_always_active
0
100
23.0
1
1
NIL
HORIZONTAL

SLIDER
894
426
1119
459
iphone_with_physical_web_app
iphone_with_physical_web_app
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
1151
452
1470
485
bluetooth_probability_if_not_always_active
bluetooth_probability_if_not_always_active
0
100
24.0
1
1
NIL
HORIZONTAL

SLIDER
940
317
1169
350
cafeteria_interaction_probability
cafeteria_interaction_probability
0
100
2.0
1
1
NIL
HORIZONTAL

SLIDER
1166
317
1418
350
lecture_room_interaction_probability
lecture_room_interaction_probability
0
100
7.0
1
1
NIL
HORIZONTAL

INPUTBOX
1244
255
1399
315
students_at_erba
1400
1
0
Number

SLIDER
1409
255
1756
288
aditional_percentage_of_students_per_timeslot
aditional_percentage_of_students_per_timeslot
0
100
25
1
1
NIL
HORIZONTAL

SLIDER
1410
295
1611
328
leave_or_sit_probability
leave_or_sit_probability
0
100
18
1
1
NIL
HORIZONTAL

SLIDER
1411
339
1613
372
skip_lecture_probability
skip_lecture_probability
0
100
30
1
1
NIL
HORIZONTAL

MONITOR
673
67
814
112
Students at Cafeteria
students_at_cafeteria
17
1
11

MONITOR
674
121
803
166
Students at Library
students_at_library
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.1
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
