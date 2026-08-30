extends Node

const PORT = 9999

var peer: ENetMultiplayerPeer

func crear_host():
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(PORT)
	
	if error != OK:
		print("Error al crear el host")
		return
	
	multiplayer.multiplayer_peer = peer
	
	print("Host hecho y derecho")

func conectar_al_host(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(ip, PORT)

	if error != OK:
		print("Error al conectar: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Intentando conectar al host...")

func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass
