extends Control

#Preguntas (12)
var preguntas = ["¿Que es 
el cubismo?", #1
"¿Que tipos 
de cubismo hay?", #2
"¿Diferencia 
entre Cubismo 
Analítico
y Cubismo 
Sintetico?", #3
"¿Por qué se 
lo llama 
'cubismo analítico' ?", #4
"¿Quiénes fueron 
los principales 
representantes 
del cubismo 
analítico?", #5
"¿Cuáles son las
 principales
características 
del cubismo 
analítico?", #6
"¿Qué artista 
junto con 
Pablo Picasso 
fue fundamental 
en el 
desarrollo del 
cubismo analítico?", #7
"¿Cómo se 
representan 
los objetos en el 
cubismo analítico?", #8
"¿Qué relación existe 
entre el 
cubismo analítico 
y la fragmentación 
de las formas?", #9
"¿Qué ocurre con
 la perspectiva
 tradicional en el 
cubismo analítico?", #10
"¿Qué buscaban
 explorar Picasso
 y Braque mediante 
el cubismo analítico?", #11
"¿Qué colores 
predominan 
generalmente 
en el cubismo 
analítico?" #12
]

@onready var sonidoRespuesta: AudioStreamPlayer2D = $Answer/AnswerButtonSound


func _ready() -> void:
	$VBoxInterfaz/Question.text = preguntas[GameData.pregunta_actual]


func _on_answer_button_pressed() -> void:
	sonidoRespuesta.play()
	GameData.pregunta_actual += 1
	GameData.jugador_actual +=1
	if GameData.pregunta_actual >= preguntas.size():
		GameData.pregunta_actual = 0
		get_tree().change_scene_to_file("res://src/scenes/winner_team.tscn")
	else:
		#await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://src/scenes/team_players.tscn")
