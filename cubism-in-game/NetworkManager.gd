extends Node

const PORT = 9999

var peer: ENetMultiplayerPeer

signal conexion_exitosa
signal conexion_fallida

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func crear_host():
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(PORT)
	
	if error != OK:
		print("Error al crear el host")
		return false
	
	multiplayer.multiplayer_peer = peer
	
	print("Host hecho y derecho")
	return OK

func conectar_al_host(ip: String) -> void:
	peer = ENetMultiplayerPeer.new()
	
	print("Intentando conectar a: ", ip, ":", PORT)
	
	var error = peer.create_client(ip, PORT)

	if error != OK:
		print("Error al conectar: ", error)
		return

	multiplayer.multiplayer_peer = peer

	print("Intentando conectar al host...")

func _on_peer_connected(id: int) -> void:
	print("Se conectó un peer. ID: ", id)


func _on_peer_disconnected(id: int) -> void:
	print("Se desconectó un peer. ID: ", id)


func _on_connected_to_server():
	print("¡¡¡CLIENTE CONECTADO AL HOST!!!")
	conexion_exitosa.emit()
	return true


func _on_connection_failed() -> void:
	conexion_fallida.emit()
	print("La conexión falló 💀")
