extends Node

const PORT = 9999 #puerto default

var peer: ENetMultiplayerPeer #el goat
var jugadores_conectados := 0 #contador de jugadores

#Señales señalosas
signal conexion_exitosa
signal conexion_fallida

signal peer_conectado(id)
signal peer_desconectado(id)

#señales señalosas versión equipos
signal ambos_equipos_listos
signal equipo_liberado(equipo)
signal equipo_asignado_admin(equipo, peer_id)
#señales señalosas versión preguntas
var pregunta_bloqueada := false
var peer_que_respondio := 0

signal respuesta_ganadora(equipo, peer_id)
signal pregunta_actualizada(numero_pregunta)
signal respuesta_procesada(correcta, equipo)

#El goat se va a encargar de quien posee cada equipo
var equipo1_peer := 0
var equipo2_peer := 0

signal equipo_asignado(equipo)
signal equipo_rechazado

#el goat conoce los nombres de los participantes
var nombres_peer = {}
signal turno_actualizado(nombre_jugador)

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

@rpc("any_peer", "call_remote", "reliable")
func registrar_nombres(nombres: Array) -> void:
	var id_solicitante = multiplayer.get_remote_sender_id()
	nombres_peer[id_solicitante] = nombres
	print("Nombres registrados del peer ", id_solicitante, ": ", nombres)
	#Guardamos los nombres en el GameData del HOST
	if id_solicitante == equipo1_peer:
		GameData.jugadores_equipo1 = nombres
		print("HOST: jugadores del Equipo 1 = ", GameData.jugadores_equipo1)
	elif id_solicitante == equipo2_peer:
		GameData.jugadores_equipo2 = nombres
		print("HOST: jugadores del Equipo 2 = ", GameData.jugadores_equipo2)

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
		pregunta_actualizada.emit(GameData.pregunta_actual)
		_anunciar_pregunta.rpc(GameData.pregunta_actual) 
		_avisar_ambos_listos.rpc()

@rpc("authority", "call_remote", "reliable")
func _avisar_ambos_listos() -> void:
	ambos_equipos_listos.emit() #señalización para team_players.gd 

@rpc("any_peer", "call_remote", "reliable")
func intentar_responder() -> void:
	var id_solicitante = multiplayer.get_remote_sender_id() #manda una señal queriendo contestar
	if pregunta_bloqueada:
		print("El peer ", id_solicitante, " llegó tarde")
		return
	
	pregunta_bloqueada = true
	peer_que_respondio = id_solicitante
	
	var equipo_ganador := 0
	
	if id_solicitante == equipo1_peer:
		equipo_ganador = 1
	elif id_solicitante == equipo2_peer:
		equipo_ganador = 2
	
	print("El Equipo ", equipo_ganador, " ganó el derecho a responder, es crack")
	
	#Avisamos al Admin
	print("NETWORK: Equipo ganador = ", equipo_ganador)
	respuesta_ganadora.emit(equipo_ganador, id_solicitante)
	_anunciar_respuesta_ganadora.rpc(equipo_ganador, id_solicitante)

@rpc("any_peer", "call_remote", "reliable")
func procesar_respuesta(correcta: bool) -> void:
	if not multiplayer.is_server():
		return
	if not pregunta_bloqueada:
		return
	
	var equipo = 0
	
	if peer_que_respondio == equipo1_peer:
		equipo = 1
	elif peer_que_respondio == equipo2_peer:
		equipo = 2
	if equipo == 0:
		return
	if correcta:
		if equipo == 1:
			GameData.puntaje_equipo1 += 5
		else:
			GameData.puntaje_equipo2 += 5
	else:
		if equipo == 1:
			GameData.puntaje_equipo2 += 5
		else:
			GameData.puntaje_equipo1 += 5
	
	print("Resultado: ", "correcta gg" if correcta else "incorrecta nt")
	print("Puntaje Equipo 1: ", GameData.puntaje_equipo1)
	print("Puntaje Equipo 2: ", GameData.puntaje_equipo2)
	
	respuesta_procesada.emit(correcta, equipo)

func _avanzar_pregunta() -> void:
	if GameData.pregunta_actual >= 11:
		print("Se terminaron las 12 preguntas")
		if GameData.puntaje_equipo1 > GameData.puntaje_equipo2:
			GameData.equipo_ganador = 1
		elif GameData.puntaje_equipo2 > GameData.puntaje_equipo1:
			GameData.equipo_ganador = 2
		else:
			GameData.equipo_ganador = 0
		
		print("Puntaje final Equipo 1: ", GameData.puntaje_equipo1)
		print("Puntaje final Equipo 2: ", GameData.puntaje_equipo2)
		print("Ganador: ", GameData.equipo_ganador)
		
		_anunciar_ganador.rpc(GameData.equipo_ganador)
		get_tree().change_scene_to_file("res://src/scenes/winner_team.tscn")
		return

	GameData.pregunta_actual += 1
	pregunta_bloqueada = false
	peer_que_respondio = 0
	pregunta_actualizada.emit(GameData.pregunta_actual)
	_anunciar_pregunta.rpc(GameData.pregunta_actual)

@rpc("authority", "call_remote", "reliable")
func _anunciar_pregunta(numero_pregunta: int) -> void:
	GameData.pregunta_actual = numero_pregunta
	pregunta_actualizada.emit(numero_pregunta)

@rpc("authority", "call_remote", "reliable")
func _anunciar_respuesta_ganadora(equipo: int, peer_id: int) -> void:
	respuesta_ganadora.emit(equipo, peer_id)

@rpc("authority", "call_remote", "reliable")
func _anunciar_ganador(equipo: int) -> void:
	GameData.equipo_ganador = equipo
	get_tree().change_scene_to_file("res://src/scenes/winner_team.tscn")

func avanzar_jugadores() -> void:

	# Avanzamos jugador del Equipo 1
	if GameData.jugadores_equipo1.size() > 0:
		GameData.jugador_actual_equipo1 += 1
		
		if GameData.jugador_actual_equipo1 >= GameData.jugadores_equipo1.size():
			GameData.jugador_actual_equipo1 = 0

	# Avanzamos jugador del Equipo 2
	if GameData.jugadores_equipo2.size() > 0:
		GameData.jugador_actual_equipo2 += 1
		
		if GameData.jugador_actual_equipo2 >= GameData.jugadores_equipo2.size():
			GameData.jugador_actual_equipo2 = 0

	# Le mandamos a cada celular SOLO su jugador
	if equipo1_peer != 0 and GameData.jugadores_equipo1.size() > 0:
		var nombre_equipo1 = GameData.jugadores_equipo1[GameData.jugador_actual_equipo1]
		_anunciar_turno.rpc_id(equipo1_peer, nombre_equipo1)

	if equipo2_peer != 0 and GameData.jugadores_equipo2.size() > 0:
		var nombre_equipo2 = GameData.jugadores_equipo2[GameData.jugador_actual_equipo2]
		_anunciar_turno.rpc_id(equipo2_peer, nombre_equipo2)
	
	print("HOST equipo 1: ", GameData.jugadores_equipo1)
	print("HOST equipo 2: ", GameData.jugadores_equipo2)

@rpc("authority", "call_remote", "reliable")
func _anunciar_turno(nombre_jugador: String) -> void:
	turno_actualizado.emit(nombre_jugador)
