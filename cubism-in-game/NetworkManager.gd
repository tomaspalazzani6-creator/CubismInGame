extends Node

const PORT = 9999 #puerto default

var peer: ENetMultiplayerPeer #el goat
var jugadores_conectados := 0 #contador de jugadores

#Señales señalosas
signal conexion_exitosa
signal conexion_fallida

signal peer_conectado(id)
signal peer_desconectado(id)

signal ambos_equipos_listos
signal equipo_liberado(equipo)
signal equipo_asignado_admin(equipo, peer_id)

#El goat se va a encargar de quien posee cada equipo
var equipo1_peer := 0
var equipo2_peer := 0

signal equipo_asignado(equipo)
signal equipo_rechazado

#check quien esta listo
var equipo1_listo := false
var equipo2_listo := false

func _ready() -> void: #Aura funcs
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
	if jugadores_conectados >= 2:
		print("Sala llena compa")
		multiplayer.multiplayer_peer.disconnect_peer(id)
		return
	
	jugadores_conectados +=1
	peer_conectado.emit(id)
	print("Se conectó un peer, su DNI: ", id)

func _on_peer_disconnected(id: int) -> void:
	jugadores_conectados -=1
	peer_desconectado.emit(id)
	print("Se desconectó un peer, su DNI: ", id)
	
	# Liberamos el equipo que ocupaba
	if equipo1_peer == id:
		equipo1_peer = 0
		equipo1_listo = false
		equipo_liberado.emit(1)
		print("Equipo 1 se quedo libre")

	if equipo2_peer == id:
		equipo2_peer = 0
		equipo2_listo = false
		equipo_liberado.emit(2)
		print("Equipo 2 se quedo libre")

func _on_connected_to_server():
	print("cliente conectado chavalin")
	conexion_exitosa.emit()
	return true


func _on_connection_failed() -> void:
	conexion_fallida.emit()
	print("la conexión falló, disculpa")

@rpc("any_peer", "call_remote", "reliable") #RPC
func solicitar_equipo(equipo: int) -> void: #el 1 es el ID del host y el ultimo 1 significa tipo: quiero el Equipo 1
	var id_solicitante = multiplayer.get_remote_sender_id() #El host obtiene automáticamente quién hizo la solicitud
	#bien sigma boy, tipo: peer 2 solicita el equipo 1

	if equipo == 1:
		if equipo1_peer == 0:
			equipo1_peer = id_solicitante
			print("Equipo 1 asignado al peer: ", id_solicitante)
			_confirmar_equipo.rpc_id(id_solicitante, 1) #solamente le responde a ese peer
			equipo_asignado_admin.emit(1, id_solicitante)
		else:
			print("El Equipo 1 ya está ocupado")
			_rechazar_equipo.rpc_id(id_solicitante)

	elif equipo == 2:
		if equipo2_peer == 0:
			equipo2_peer = id_solicitante
			print("Equipo 2 asignado al peer: ", id_solicitante)
			_confirmar_equipo.rpc_id(id_solicitante, 2)
			equipo_asignado_admin.emit(2, id_solicitante)
		else:
			print("El Equipo 2 ya está ocupado")
			_rechazar_equipo.rpc_id(id_solicitante)


@rpc("authority", "call_remote", "reliable")
func _confirmar_equipo(equipo: int) -> void:
	equipo_asignado.emit(equipo)


@rpc("authority", "call_remote", "reliable")
func _rechazar_equipo() -> void: #aca emite la señal para el team_selector, pieza clave
	equipo_rechazado.emit()

@rpc("any_peer", "call_remote", "reliable")
func avisar_listo(equipo: int) -> void:
	var id_solicitante = multiplayer.get_remote_sender_id()

	if equipo == 1 and equipo1_peer == id_solicitante: #evita que un peer cualquiera pueda decir "hola soy equipo 1 y estoy listo"
		equipo1_listo = true
		print("Equipo 1 esta listo")

	elif equipo == 2 and equipo2_peer == id_solicitante:
		equipo2_listo = true
		print("Equipo 2 esta listo")

	if equipo1_listo and equipo2_listo:
		print("ambos conjuntos tienen su 11 ideal xd")
		_avisar_ambos_listos.rpc()

@rpc("authority", "call_remote", "reliable")
func _avisar_ambos_listos() -> void:
	ambos_equipos_listos.emit() #señalización para team_players.gd 
