extends Control

@onready var aviso: Label = $VBoxInterfaz1/Aviso
@onready var player1: Label = $PlayersConnected/player1
@onready var player2: Label = $PlayersConnected/player2

var jugadores = 0


func _ready() -> void:
	aviso.text = ''
	player1.text = "Jugador1: No"
	player2.text = "Jugador2: No"
	NetworkManager.peer_conectado.connect(_jugador_conectado)
	NetworkManager.peer_desconectado.connect(_jugador_desconectado)


func _jugador_conectado() -> void:
	jugadores += 1

	if jugadores == 1:
		player1.text = "Jugador1: Sí"

	elif jugadores == 2:
		player2.text = "Jugador2: Sí"


func _jugador_desconectado() -> void:
	jugadores -= 1

	if jugadores < 2:
		player2.text = "Jugador2: No"

	if jugadores < 1:
		player1.text = "Jugador1: No"

func obtener_ip_local() -> String:
	var ips = IP.get_local_addresses()

	for ip in ips:
		if ip.begins_with("192.168."):
			return ip

	return "IP no encontrada"

func _on_host_button_pressed() -> void:
	aviso.text = "Botón presionado"
	var resultado = NetworkManager.crear_host()
	
	if resultado == OK:
		aviso.text = 'Host creado: si\nIP: ' + obtener_ip_local()
	else:
		aviso.text = 'Host creado: No'
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
