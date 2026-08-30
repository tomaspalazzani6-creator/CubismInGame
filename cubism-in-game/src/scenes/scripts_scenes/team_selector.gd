extends Control

var team1selected = false
var team2selected = false

func _ready() -> void:
	pass 


func _process(_delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")


func _on_team_1_pressed() -> void:
	GameData.team1_selected = true
	GameData.team2_selected = false
	get_tree().change_scene_to_file("res://src/scenes/enter_name.tscn")


func _on_team_2_pressed() -> void:
	GameData.team2_selected = true
	GameData.team1_selected = false
	get_tree().change_scene_to_file("res://src/scenes/enter_name.tscn")
