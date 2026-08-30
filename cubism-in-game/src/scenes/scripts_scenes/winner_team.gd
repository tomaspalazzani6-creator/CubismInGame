extends Control

@onready var teamName: Label = $VBoxInterfaz/TeamName


func _ready() -> void:
	if GameData.team1_selected:
		teamName.text = 'EQUIPO 1'
	else:
		teamName.text = 'EQUIPO 2'

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
