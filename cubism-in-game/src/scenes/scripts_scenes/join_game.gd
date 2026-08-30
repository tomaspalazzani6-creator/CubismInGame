extends Control

var IPingresada
@onready var alert: Label = $ButtonContainer/alert


func _ready() -> void:
	alert.text = ''
	
	NetworkManager.conexion_exitosa.connect(_conexion_exitosa)
	NetworkManager.conexion_fallida.connect(_conexion_fallida)



func _on_join_pressed() -> void:
	IPingresada = $ButtonContainer/enterIP.text
	NetworkManager.conectar_al_host(IPingresada)
	
	alert.text = "Conectando a: " + IPingresada + ":9999"

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")

func _conexion_exitosa() -> void:
	alert.text = "Conectado al host"


func _conexion_fallida() -> void:
	alert.text = "Conexión fallida"
