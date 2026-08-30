extends Control


var jugadores = [] #la lista
var cantJugadores
var cantidadPrefijada = false



func _ready() -> void:
	$VBoxInterfaz/TextField/LineEdit.editable = false


func _process(_delta: float) -> void:
	pass


func _on_add_button_pressed() -> void: #este botón añade los nombres a la lista
	var nombre = $VBoxInterfaz/TextField/LineEdit.text.strip_edges()
	cantJugadores = int($VBoxInterfaz/TextField/PlayerNumbers.text)
	
	#se eligió la cantidad? checkeo
	if cantJugadores == 0:
		return
	elif cantJugadores != 0:
		cantidadPrefijada = true
	
	if cantidadPrefijada == true:
		$VBoxInterfaz/TextField/LineEdit.editable = true
	
	#se ingresó siquiera un nombre? check
	if nombre == "":
		print("no se ingreso nada")
		return

	
	#Maximo de jugadores
	if jugadores.size() >= cantJugadores:
		print("Ya se alcanzó el máximo de jugadores")
		return
	
	
	var label = Label.new()
	label.text = nombre
	
	#cositas visuales para el label
	label.add_theme_font_size_override("font_size", 45)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$VBoxInterfaz/PlayerList.add_child(label)
	
	jugadores.append(nombre) #se agregan los nombres a la lista de jugadores
	jugadores.sort()
	
	
	
	#guardamos los jugadores en la GameData
	if GameData.team1_selected:
		GameData.jugadores_equipo1 = jugadores
	else:
		GameData.jugadores_equipo2 = jugadores
	
	$VBoxInterfaz/TextField/LineEdit.clear() #limpiamos el textfield
	
	print(jugadores) #pa testeo (muestra por consola la lista)
