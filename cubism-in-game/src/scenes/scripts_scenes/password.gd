extends Control

var contraseña
@onready var alert: Label = $Alert


func _ready() -> void:
	pass


func _on_ok_button_pressed() -> void:
	contraseña = $VBoxInterfaz/passwordText.text
	
	if contraseña == 'sant@m':
		get_tree().change_scene_to_file("res://src/scenes/admin.tscn")
	else:
		alert.text = 'Contraseña Incorrecta'
		await get_tree().create_timer(2.0).timeout
		alert.text = ''
