extends Control


func _ready() -> void:
	pass 

func _on_host_button_pressed() -> void:
	NetworkManager.crear_host()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
