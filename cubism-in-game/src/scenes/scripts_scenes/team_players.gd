extends Control

var celdas = []
var labels_jugadores = []
var estoy_listo := false

func _ready() -> void:
	NetworkManager.ambos_equipos_listos.connect(_ambos_equipos_listos)
	
	var jugadores
	if GameData.team1_selected:
		$VBoxInterfaz/Title.text = "EQUIPO 1"
	else:
		$VBoxInterfaz/Title.text = "EQUIPO 2"
	
	if GameData.team1_selected:
		jugadores = GameData.jugadores_equipo1
	else:
		jugadores = GameData.jugadores_equipo2
	
	for nombre in jugadores:
		var celda = PanelContainer.new()
		
		var label = Label.new()
		label.text = nombre
		
		label.add_theme_font_size_override("font_size", 60)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		celda.custom_minimum_size = Vector2(0, 60)
		celda.add_child(label)
		$VBoxInterfaz/PlayerBox/PlayerList.add_child(celda)
		
		celdas.append(celda)
		labels_jugadores.append(label)

func _selecionar_jugador() -> void:
	#si se acaban los jugadores de la lista, empezar devuelta
	if GameData.jugador_actual >= labels_jugadores.size():
		GameData.jugador_actual = 0
	
	
	var jugador = labels_jugadores[GameData.jugador_actual]

	var tween = create_tween()

	# agrandamos y cambiamos el colorsito
	tween.set_parallel(true)

	tween.tween_property(
		jugador,
		"scale",
		Vector2(1.04, 1.04),
		0.5
	)

	tween.tween_property(
		jugador,
		"modulate",
		Color(0.6, 1.0, 0.6),
		0.5
	)

	tween.set_parallel(false)

	tween.tween_interval(1.3) #tiempo de la anim

	#vuelve al estado normal
	tween.set_parallel(true)

	tween.tween_property(
		jugador,
		"scale",
		Vector2(1, 1),
		0.5
	)

	tween.tween_property(
		jugador,
		"modulate",
		Color.WHITE,
		0.5
	)
	
	
	

func _on_ready_button_pressed() -> void:
	if estoy_listo:
		return
	
	estoy_listo = true
	
	$BotonAparte/ReadyButton.disabled = true
	$BotonAparte/WaitingLabel.text = "esperando al otro equipo..."
	
	var equipo
	
	if GameData.team1_selected:
		equipo = 1
	else:
		equipo = 2
	
	NetworkManager.avisar_listo.rpc_id(1, equipo)


func _ambos_equipos_listos() -> void:
	$VBoxInterfaz/WaitingLabel.text = "ambos estan ready"
	_selecionar_jugador()
	await get_tree().create_timer(1.4).timeout
	get_tree().change_scene_to_file("res://src/scenes/question_scene.tscn")
