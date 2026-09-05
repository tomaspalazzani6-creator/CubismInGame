extends Control

var team1selected = false
var team2selected = false

func _ready() -> void:
	NetworkManager.equipo_asignado.connect(_equipo_asignado)
	NetworkManager.equipo_rechazado.connect(_equipo_rechazado)


func _process(_delta: float) -> void:
	pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_menu.tscn")


func _on_team_1_pressed() -> void:
	NetworkManager.solicitar_equipo.rpc_id(1, 1)

func _on_team_2_pressed() -> void:
	NetworkManager.solicitar_equipo.rpc_id(1, 2)

#queda piola, hace un checkeo para ver los equipos disponibles

func _equipo_asignado(equipo: int) -> void:
	if equipo == 1:
		GameData.team1_selected = true
		GameData.team2_selected = false

	elif equipo == 2:
		GameData.team1_selected = false
		GameData.team2_selected = true

	get_tree().change_scene_to_file("res://src/scenes/enter_name.tscn")


func _equipo_rechazado() -> void:
	print("este equipo ya esta ocupado, nt")
