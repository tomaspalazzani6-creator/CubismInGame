extends Control

@onready var aviso: Label = $VBoxInterfaz1/Aviso


func _ready() -> void:
	aviso.text = ''

func _on_host_button_pressed() -> void:
	aviso.text = "Botón presionado"
	var resultado = NetworkManager.crear_host()
	
	if resultado == OK:
		aviso.text = 'Host creado: si'
	else:
		aviso.text = 'Host creado: No\nError: ' + str(resultado)
	


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
