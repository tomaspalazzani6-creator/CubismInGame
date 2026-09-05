extends Control

@onready var aviso: Label = $VBoxInterfaz1/Aviso
@onready var player1: Label = $PlayersConnected/player1
@onready var player2: Label = $PlayersConnected/player2
@onready var team1: Label = $TeamsSelected/Team1
@onready var team2: Label = $TeamsSelected/Team2

var jugadores = 0

var jugador1_peer := 0
var jugador2_peer := 0


func _ready() -> void:
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


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
