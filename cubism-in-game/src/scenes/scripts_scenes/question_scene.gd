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
@onready var answer_button: Button = $Answer/AnswerButton
@onready var next_players: Label = $NextPlayers


func _ready() -> void:
	$VBoxInterfaz/Question.text = preguntas[GameData.pregunta_actual]
	next_players.visible = false
	NetworkManager.respuesta_ganadora.connect(_respuesta_ganadora)
	NetworkManager.pregunta_actualizada.connect(_pregunta_actualizada)
	NetworkManager.turno_actualizado.connect(_turno_actualizado)


func _on_answer_button_pressed() -> void:
	sonidoRespuesta.play()
	NetworkManager.intentar_responder.rpc_id(1)

func _respuesta_ganadora(equipo: int, _peer_id: int) -> void:
	#desactivamos el boton total ya hubo ganador
	answer_button.disabled = true
	if GameData.team1_selected and equipo == 1:
		print("mi equipo god, gano la respuesta zzz")
	elif GameData.team2_selected and equipo == 2:
		print("mi equipo de goats, gano la respuesta ez")
	else:
		print("wtf amigo, vos estas re loco")

func _pregunta_actualizada(numero_pregunta: int) -> void:
	$VBoxInterfaz/Question.text = preguntas[numero_pregunta]
	answer_button.disabled = false
	next_players.visible = false

func _turno_actualizado(nombre_jugador: String) -> void:
	next_players.text = "Siguiente jugador:\n" + nombre_jugador
	next_players.visible = true
