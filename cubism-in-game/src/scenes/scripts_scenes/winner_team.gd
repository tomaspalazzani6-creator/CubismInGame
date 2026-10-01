extends Control

@onready var teamName: Label = $VBoxInterfaz/TeamName
@onready var wintext: Label = $VBoxInterfaz/WinText




func _ready() -> void:
	wintext.text = '          Gracias 
	             por 
	           jugar!'
	if GameData.equipo_ganador == 1:
		teamName.text = 'EQUIPO 1'
	elif GameData.equipo_ganador == 2:
		teamName.text = 'EQUIPO 2'
	else:
		teamName.text = 'EMPATE'


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
