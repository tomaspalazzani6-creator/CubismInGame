extends Control

@onready var aviso: Label = $VBoxInterfaz1/Aviso
@onready var player1: Label = $PlayersConnected/player1
@onready var player2: Label = $PlayersConnected/player2
@onready var team1: Label = $TeamsSelected/Team1
@onready var team2: Label = $TeamsSelected/Team2
@onready var questionInGame: Label = $VBoxInterfaz2/QuestionInGame
@onready var correct_answer: Label = $VBoxInterfaz2/CorrectAnswer
@onready var firstTeamAnswer: Label = $VBoxInterfaz2/FirstTeamAnswer



var jugadores = 0

var jugador1_peer := 0
var jugador2_peer := 0

#Copia exacta del array de preguntas de la escena question
#(12)
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

#Respuestas:
var respuestas = [
	"Movimiento artístico que representa la realidad mediante formas geométricas y múltiples puntos de vista.", #1
	"El cubismo analítico y el cubismo sintético.", #2
	"El analítico descompone las formas; el sintético las simplifica y combina con elementos nuevos.", #3
	"Porque analiza y descompone los objetos en múltiples planos y puntos de vista.", #4
	"Pablo Picasso y Georges Braque.", #5
	"Fragmentación de las formas, múltiples perspectivas, geometrización y colores apagados.", #6
	"Georges Braque.", #7
	"Los objetos aparecen fragmentados y vistos desde varios puntos de vista simultáneamente.", #8
	"La fragmentación permite analizar un objeto y mostrar distintas partes o perspectivas al mismo tiempo.", #9
	"Se abandona la perspectiva tradicional y se utilizan múltiples puntos de vista.", #10
	"Explorar nuevas formas de representar la realidad y analizar los objetos desde distintos puntos de vista.", #11
	"Predominan los colores apagados y terrosos, como grises, ocres, marrones y verdes.", #12
]

func _ready() -> void:
	#textos
	aviso.text = ''
	player1.text = "Jugador1: No"
	player2.text = "Jugador2: No"
	team1.text = "Equipo1: sin asignar"
	team2.text = "Equipo2: sin asignar"
	
	#señales
	NetworkManager.peer_conectado.connect(_jugador_conectado)
	NetworkManager.peer_desconectado.connect(_jugador_desconectado)
	NetworkManager.equipo_asignado_admin.connect(_equipo_asignado)
	NetworkManager.equipo_liberado.connect(_equipo_liberado)
	NetworkManager.respuesta_ganadora.connect(_respuesta_ganadora)
	NetworkManager.pregunta_actualizada.connect(_pregunta_actualizada)


func _jugador_conectado(id: int) -> void:
	jugadores += 1

	if jugadores == 1:
		jugador1_peer = id
		player1.text = "Jugador1:Si"

	elif jugadores == 2:
		jugador2_peer = id
		player2.text = "Jugador2:Si"


func _jugador_desconectado(id: int) -> void:
	jugadores -= 1
	
	if id == jugador1_peer:
		jugador1_peer = 0
		player1.text = "Jugador1:No"
	if id == jugador2_peer:
		jugador2_peer = 0
		player2.text = "Jugador2:No"


func _equipo_asignado(equipo: int, peer_id: int) -> void:
	if equipo == 1:
		team1.text = "Equipo1: " + _obtener_nombre_jugador(peer_id)
	elif equipo == 2:
		team2.text = "Equipo2: " + _obtener_nombre_jugador(peer_id)

func _equipo_liberado(equipo: int) -> void:
	if equipo == 1:
		team1.text = "Equipo1: sin asignar"
	elif equipo == 2:
		team2.text = "Equipo2: sin asignar"

func _obtener_nombre_jugador(peer_id: int) -> String:
	if peer_id == jugador1_peer:
		return "Jugador1"

	if peer_id == jugador2_peer:
		return "Jugador2"

	return "ni idea"

func _obtener_jugador_actual(equipo: int) -> String:
	var jugadores_equipo
	
	if equipo == 1:
		jugadores_equipo = GameData.jugadores_equipo1
	else:
		jugadores_equipo = GameData.jugadores_equipo2
	if jugadores_equipo.is_empty():
		return "Sin jugadores"
	if GameData.jugador_actual >= jugadores_equipo.size():
		return jugadores_equipo[0]
	
	return jugadores_equipo[GameData.jugador_actual]

func obtener_ip_local() -> String:
	var ips = IP.get_local_addresses()
	for ip in ips:
		if ip.begins_with("192.168."):
			return ip
	return "IP no encontrada"


func _on_host_button_pressed() -> void:
	aviso.text = "boton presionado"
	var resultado = NetworkManager.crear_host()
	if resultado == OK:
		aviso.text = 'Host creado: si\nIP: ' + obtener_ip_local()
	else:
		aviso.text = 'Host creado: No'

func _obtener_nombre_por_peer(peer_id: int) -> String:
	if not NetworkManager.nombres_peer.has(peer_id):
		return "Sin nombres registrados"
	
	var jugadores_id = NetworkManager.nombres_peer[peer_id]
	
	if jugadores_id.is_empty():
		return "Sin jugadores"
	if GameData.jugador_actual >= jugadores.size():
		return jugadores_id[0]
	return jugadores_id[GameData.jugador_actual]

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")

func _pregunta_actualizada(numero_pregunta: int) -> void:
	questionInGame.text = preguntas[numero_pregunta]
	correct_answer.text = respuestas[numero_pregunta]
	
	firstTeamAnswer.text = "Primer equipo: "

func _respuesta_ganadora(equipo: int) -> void:
	firstTeamAnswer.text = "Primer equipo: Equipo " + str(equipo)

#Apartir de aca se encuentran los botones
#que sirven para dar puntos o transferirlos 
#al otro equipo

#Esta sección para el equipo 1 (quitarle o sumarle)
func _on_get_points_t_1_pressed() -> void:
	NetworkManager.procesar_respuesta(true)
	await get_tree().create_timer(1.4).timeout
	#aca tocaríamos el "avanzar pregunta" para movernos a la siguiente


func _on_transfer_points_t_1_pressed() -> void:
	NetworkManager.procesar_respuesta(false)
	await get_tree().create_timer(1.4).timeout
	#aca tocaríamos el "avanzar pregunta" para movernos a la siguiente

#Esta sección para el equipo 2(lo mismo, quitarle o sumarle)
func _on_get_points_t_2_pressed() -> void:
	NetworkManager.procesar_respuesta(true)
	await get_tree().create_timer(1.4).timeout
	#aca tocaríamos el "avanzar pregunta" para movernos a la siguiente


func _on_transfer_points_t_2_pressed() -> void:
	NetworkManager.procesar_respuesta(false)
	await get_tree().create_timer(1.4).timeout
	#aca tocaríamos el "avanzar pregunta" para movernos a la siguiente
