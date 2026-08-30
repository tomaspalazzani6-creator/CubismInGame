extends Control


func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass
	


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/team_selector.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_host_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/password.tscn")
