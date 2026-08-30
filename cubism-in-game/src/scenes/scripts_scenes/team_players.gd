extends Control

var celdas = []
var labels_jugadores = []
var jugador_actual = 0

func _ready() -> void:
	var jugadores
	
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
	var jugador = labels_jugadores[jugador_actual]

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

	tween.tween_interval(1.3)

	# vuelve al estado normal
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
	
	#pasar al siguiente jugador
	jugador_actual += 1
	
	#si se acaban los jugadores de la lista, empezar devuelta
	if jugador_actual >= labels_jugadores.size():
		jugador_actual = 0
	


func _on_ready_button_pressed() -> void:
	_selecionar_jugador()
