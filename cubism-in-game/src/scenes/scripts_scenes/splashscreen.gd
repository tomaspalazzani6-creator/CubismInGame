extends Control


@onready var animationplayer: AnimationPlayer = $AnimationPlayer



func _ready() -> void:
	animationplayer.play("fadeIn")
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")
