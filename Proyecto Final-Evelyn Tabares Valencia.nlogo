;Creado por : Evelyn Tabares Valencia  2020/12
globals [sanos infectados recuperados muertos  ]
breed[Personas Persona]
Personas-own[  edad Enf_preexistente COVID-19 d_contagiado Desobedece]
;color 26 naranja -> Persona Infectada
;color 85 azul -> Persona recuperada
;color white -> Persona sana
; color 135 rosado -> Persona en cuarentena

to iniciar
  ca
  reset-ticks
  ask patches [ set pcolor 4];cambia color del todas las parcelas
   create-personas 500
  [
    set  shape "person sana"
    set size 1.8
    set Enf_preexistente random 2 ;(entre 0 y N-1) -> enfermedad : 1 , sin_enfermedad : 0
    set edad  random 101 ;(entre 0 y N-1) -> edad de 0-100
    set COVID-19 0; COVID-19: 1, SIN COVID-19 : 0
    set d_contagiado 0; dias contagiado
    set Desobedece  0; Desobedece al gobierno : 1 , Obediente : 0
  ]

   ask personas
   [
    set xcor  random-xcor
    set ycor  random-ycor

   ]
end


;---------------LIBERTAD TOTAL-------------------------------------------------------------

to Libertad_total
  tick
  if (ticks = 365)
     [stop]

  set sanos count personas with [ shape  = "person sana"]; Contador de sanos


  if(sanos = 500)
     [  ask one-of personas [set shape   "enfermo" set COVID-19 1]
        ask  n-of ( 500 * desobedientes ) personas with [shape  = "person sana"][ set pcolor 135 set Desobedece 1 ]
     ];Inicia con una persona infectada

  ask personas with [Desobedece = 0] [fd 1 rt random 360] ; moverse

  ask personas with [ COVID-19 = 1 and Desobedece = 0] [ ask personas in-radius 1 [
      if( shape  = "person sana" and Desobedece = 0);Persona Sana y no está en cuarentena
        [set shape   "enfermo" set  COVID-19  1 ];Contagia a las personas en un radio de 1 m
        ]recuperarse_morir  ]

  ask personas with [ COVID-19 = 1 and Desobedece = 1 ] [ask personas-here [;Contagia a quienes estén en la misma parcela
      if( shape  = "person sana" and  Desobedece = 1  );Persona Sana y está en cuarentena
        [set shape   "enfermo" set  COVID-19  1 ] ] recuperarse_morir]

  set muertos (500 - count personas) ; Contador de muertos
  set infectados count personas with [COVID-19 = 1];Contador de infectado
  set recuperados count personas with [ shape  = "recuperado"];Contador de recuperados
  update-plots
end

;------------------------RECUPERARSE_ MORIR--------------------------------------
to recuperarse_morir

  ifelse ( (  (edad < 65 ) and (d_contagiado < 30 )) and (Enf_preexistente = 0) );Personas < 65 años y enfermedad preexistente: 0
        [set d_contagiado (d_contagiado + 1)];Aumenta en 1 dia de contagio

        [ifelse( ( (edad < 65 ) and (d_contagiado = 30 )) and  (Enf_preexistente =  0) );Día de recuperación
              [  set shape "recuperado" set COVID-19 0 ] ; Se recupera en 30 dias

              [ifelse ( ( (edad >= 65) and (d_contagiado < 60 )) and (Enf_preexistente =  1)); Personas > 65 años con enfermedad preexistente : 1
                    [ifelse (d_contagiado = 18 and (random 2 = 1) )
                           [ if (pcolor = 135)[set pcolor 4] die] ;Muere
                           [set d_contagiado (d_contagiado + 1)] ] ;Aumenta en 1 dia de contagio

                    [ifelse ( ( (edad >= 65) and (d_contagiado = 60 )) and (Enf_preexistente =  1));Día de recuperación
                           [  set shape "recuperado" set COVID-19 0 ] ; Se recupera en 60 dias

                           [ifelse ( ( (edad >= 65) and (d_contagiado < 42 )) and (Enf_preexistente = 0 )); Personas > 65 años con enfermedad preexistente : 0
                                [set d_contagiado (d_contagiado + 1)];Aumenta en 1 dia de contagio

                                [ifelse ( ( (edad >= 65) and (d_contagiado = 42 )) and (Enf_preexistente =  0));Día de recuperación
                                       [  set shape "recuperado" set COVID-19 0 ] ; Se recupera en 42 dias

                                       [ifelse ( ( (edad < 65) and (d_contagiado < 42 ) ) and  ( Enf_preexistente = 1 )) ;Personas < 65 con enfermedad preexistente: 1
                                             [ifelse (d_contagiado = 18 and (random 2 = 1 ))
                                                 [ if (pcolor = 135)[set pcolor 4] die] ;Muere
                                                 [set d_contagiado (d_contagiado + 1)] ];Aumenta en 1 dia de contagio

                                             [if ( ((edad < 65) and (d_contagiado = 42 ) ) and ( Enf_preexistente = 1 ) );Día de recuperación
                                                  [  set shape "recuperado" set COVID-19 0 ]; Se recupera en 42 dias
   ]]]]]]]
   stop-inspecting-dead-agents

end
;-------------CUARENTENA----------------------------------------------------
to Cuarentena
  tick
  set sanos count personas with [ shape  = "person sana"]; Contador de sanos
  ifelse(ticks = 365);Final de la simulacion
     [stop]

     [ifelse (ticks < (meses * 30));  meses de cuarentena
        [
          if(sanos = 500)
            [  ask one-of personas [set shape "enfermo" set COVID-19 1 set Desobedece 1]
               ask  n-of ( 500 * desobedientes ) personas [ set Desobedece 1 ];Desobedientes
               ask personas with [Desobedece = 0][set pcolor 135]; Personas están en  cuarentena
            ];Inicia con una persona infectada

          ask personas with [Desobedece = 1] [fd 1 rt random 360] ; moverse

          ask personas with [ COVID-19 = 1 and Desobedece = 1 ] [ ask personas in-radius 1 [
              if( shape  = "person sana" and  Desobedece = 1  );Persona Sana y no está en cuarentena
                [set shape   "enfermo" set  COVID-19  1 ]];Contagia a las personas en un radio de 1 m
               recuperarse_morir  ]

          ask personas with [ COVID-19 = 1 and Desobedece = 0 ] [ask personas-here [ ;Contagia a quienes estén en la misma parcela
              if( shape  = "person sana" and  Desobedece = 0  );Persona Sana y está en cuarentena
              [set shape   "enfermo" set  COVID-19  1 ] ] recuperarse_morir]

        ];Durante la cuarentena

        ;------------------Termina la curentena -------------------------------------------------------

        [if ( ticks >= (meses * 30) )[;Termina la cuarentena

            set sanos count personas with [ shape  = "person sana"]; Contador de sanos

            if(ticks = (meses * 30) )
               [ask personas [set pcolor 4  set Desobedece 0 ]; salen de cuarentena
                ask  n-of  ( ( count personas  * desobedientes ) / 2 ) personas [ set Desobedece 1 ];Desobedientes que se quedan en cuarentena
                ask personas with [Desobedece = 1][set pcolor 135]; Personas que siguen la cuarentena
               ]

            ask personas with [Desobedece = 0][fd 1 rt random 360 ]; moverse

            ask personas with [ COVID-19 = 1 and Desobedece = 0 ] [ ask personas in-radius 1 [
              if( shape  = "person sana" and Desobedece = 0);Persona Sana y no está en cuarentena
                 [set shape   "enfermo" set  COVID-19  1 ];Contagia a las personas en un radio de 1 m
            ]recuperarse_morir  ]

            ask personas with [ COVID-19 = 1 and Desobedece = 1 ] [ask personas-here [;Contagia a quienes estén en la misma parcela
              if( shape  = "person sana" and  Desobedece = 1  );Persona Sana y está en cuarentena
              [set shape   "enfermo" set  COVID-19  1 ] ] recuperarse_morir]



         ]]
  ];termina el ifelse
  set muertos (500 - count personas) ; Contador de muertos
  set infectados count personas with [COVID-19 = 1];Contador de infectado
  set recuperados count personas with [ shape  = "recuperado"];Contador de recuperados
  set sanos count personas with [ shape  = "person sana"]; Contador de sanos

  update-plots

end


;---------------AISLAMIENTO MODERADO------------------------------------------------------
to Aislamiento_moderado
  tick
  set sanos count personas with [ shape  = "person sana"]; Contador de sanos

  if(ticks = 365);Final de la simulacion
     [stop]

  if(sanos = 500)
     [  ask one-of personas [set shape   "enfermo" set COVID-19 1 set Desobedece 1]
        ask  n-of ( 500 * desobedientes ) personas with [ (edad >= 65 or edad <= 12) and Desobedece = 0 ][ set Desobedece 1 ];Desobedientes
        ask personas with [ (Desobedece = 0) and (edad >= 65 or edad <= 12)][set pcolor 135]; Personas están en  cuarentena
     ];Inicia con una persona infectada

    ask personas with [(Desobedece = 1 ) or (edad < 65 and edad > 12) ] [fd 1 rt random 360] ; moverse

    ask personas with [ (COVID-19 = 1 and Desobedece = 1) or (COVID-19 = 1 and (edad < 65 and edad > 12) )] [ ask personas in-radius 1 [;SI es desobediente o uno del grupo que puede salir
        if( shape  = "person sana" and  Desobedece = 1  ) or (shape  = "person sana" and (edad < 65 and edad > 12) );Persona Sana y no está en aislamiento o desobediente sano
          [set shape   "enfermo" set  COVID-19  1 ]];Contagia a las personas en un radio de 1 m
          recuperarse_morir  ]

    ask personas with [ (COVID-19 = 1 and Desobedece = 0) and ( edad >= 65 or edad <= 12 ) ] [ask personas-here [;Contagia a quienes estén en la misma parcela
        if( shape  = "person sana" and  Desobedece = 0  );Persona Sana y está en aislamiento
           [set shape   "enfermo" set  COVID-19  1 ] ] recuperarse_morir]

   set muertos (500 - count personas) ; Contador de muertos
   set infectados count personas with [COVID-19 = 1];Contador de infectado
   set recuperados count personas with [ shape  = "recuperado"];Contador de recuperados
   set sanos count personas with [ shape  = "person sana"]; Contador de sanos


update-plots
end


;------------AISLAMIENTO EXHAUSTIVO-----------------------
to Aislamiento_exhaustivo
   tick
  set sanos count personas with [ shape  = "person sana"]; Contador de sanos

  if(ticks = 365);Final de la simulacion
     [stop]

  if(sanos = 500)
     [  ask one-of personas [set shape "enfermo" set COVID-19 1 set Desobedece 1]
        ask n-of (500 * Poblacion) personas with [Desobedece = 0][set pcolor 135 set Desobedece 2 ] ; Población aislada
        ask  n-of ( (500 * Poblacion) * desobedientes ) personas with [ Desobedece = 2][ set Desobedece 1 set pcolor 4];Desobedientes
        ;Desobedece :0 -> Población NO aislada  ;Desobedece : 2 -> Aislados
     ];Inicia con una persona infectada

  ask personas with [Desobedece = 1 or Desobedece = 0  ] [fd 1 rt random 360] ; moverse

   ask personas with [ COVID-19 = 1 and (Desobedece = 1 or Desobedece = 0)] [ ask personas in-radius 1 [
      if( shape  = "person sana" and (Desobedece = 1 or Desobedece = 0));Persona Sana y no está en cuarentena
        [set shape   "enfermo" set  COVID-19  1 ];Contagia a las personas en un radio de 1 m
        ]recuperarse_morir  ]

  ask personas with [ COVID-19 = 1 and Desobedece = 2 ] [ask personas-here [;Contagia a quienes estén en la misma parcela
      if( shape  = "person sana" and  Desobedece = 2  );Persona Sana y está en cuarentena
        [set shape   "enfermo" set  COVID-19  1 ] ] recuperarse_morir]

  set muertos (500 - count personas) ; Contador de muertos
  set infectados count personas with [COVID-19 = 1];Contador de infectado
  set recuperados count personas with [ shape  = "recuperado"];Contador de recuperados
  set sanos count personas with [ shape  = "person sana"]; Contador de sanos
update-plots
end
@#$#@#$#@
GRAPHICS-WINDOW
326
36
1111
406
-1
-1
10.951
1
10
1
1
1
0
1
1
1
-35
35
-16
16
0
0
1
dias
30.0

MONITOR
10
268
67
313
Sanos
sanos
17
1
11

MONITOR
74
269
147
314
Infectados
infectados
17
1
11

MONITOR
216
270
291
315
Recuperados
recuperados
17
1
11

MONITOR
154
269
212
314
Muertos
muertos
17
1
11

BUTTON
174
89
275
122
Cuarentena 
Cuarentena 
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
12
177
143
210
Aislamiento moderado
Aislamiento_moderado
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
163
177
291
210
Aislamiento exhaustivo
Aislamiento_exhaustivo
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
24
88
129
121
Libertad total
Libertad_total\n
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
42
15
107
48
NIL
Iniciar
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
55
334
251
498
Infectados
dias
Infectados
0.0
365.0
0.0
500.0
true
false
"" ""
PENS
"infectados" 1.0 0 -955883 true "" "plot infectados"

SLIDER
142
16
267
49
desobedientes
desobedientes
0.1
0.9
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
180
130
272
163
meses
meses
1
11
6.0
1
1
NIL
HORIZONTAL

SLIDER
173
223
272
256
Poblacion
Poblacion
0.25
1
0.75
0.25
1
NIL
HORIZONTAL

TEXTBOX
443
451
593
469
NIL
11
0.0
1

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

enfermo
false
15
Circle -955883 true false 110 5 80
Rectangle -955883 true false 127 79 172 94
Polygon -955883 true false 195 90 240 150 225 180 165 105
Polygon -955883 true false 105 90 60 150 75 180 135 105
Line -13345367 false 120 45 120 45
Circle -13345367 true false 150 60 0
Polygon -955883 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -955883 true false 120 30 105 30 90 15 120 15 120 15 135 15 150 0 165 15 210 15 195 30 150 30 210 60 195 60 90 60 105 45 135 60 105 75 195 75 165 60
Circle -2674135 true false 120 30 0
Circle -1 true true 120 30 30
Circle -1 true true 150 30 30
Polygon -16777216 true false 150 45 180 45 120 45
Polygon -2674135 true false 150 45 120 45 180 45 165 60 150 45 135 60 120 45
Line -16777216 false 135 60 135 45
Line -16777216 false 165 60 165 45

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

person sana
false
0
Circle -1 true false 110 5 80
Rectangle -1 true false 127 79 172 94
Polygon -1 true false 195 90 240 150 225 180 165 105
Polygon -1 true false 105 90 60 150 75 180 135 105
Line -13345367 false 120 45 120 45
Circle -13345367 true false 150 60 0
Rectangle -13791810 false false 120 45 180 75
Line -13345367 false 105 45 135 45
Line -13345367 false 180 45 195 45
Rectangle -13345367 true false 120 45 180 75
Polygon -1 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90

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

recuperado
false
0
Polygon -11221820 true false 195 90 240 150 225 180 165 105
Polygon -11221820 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Circle -11221820 true false 110 5 80
Rectangle -11221820 true false 127 79 172 94
Polygon -11221820 true false 105 90 60 150 75 180 135 105
Line -13345367 false 120 45 120 45
Circle -13345367 true false 150 60 0
Circle -2674135 true false 120 30 0
Polygon -16777216 true false 150 45 180 45 120 45
Polygon -1 true false 105 270 105 270 135 285
Circle -1 true false 135 45 0
Polygon -13345367 true false 105 30 195 30 180 15 120 15 105 30
Polygon -2064490 true false 135 105 135 105 165 165 135 165 135 105
Line -16777216 false 135 105 165 105
Polygon -1 true false 135 105 135 105 135 165 165 165 165 105 165 135 165 120 180 135 165 120 180 120 180 135 180 150 120 150 120 120 165 120
Line -1 false 165 105 165 120
Rectangle -1 true false 135 120 165 150
Polygon -1 true false 135 105 135 105 165 105 165 120
Polygon -1 true false 135 105 165 105 165 120 180 120 180 150 165 150 165 165 135 165 135 150 120 150 120 120 135 120 135 105

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
NetLogo 6.1.1
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
