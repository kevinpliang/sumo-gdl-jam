extends Control

func _ready() -> void:
	$CenterContainer/VBoxContainer/MenuOptions/Host.visible = false
	$CenterContainer/VBoxContainer/MenuOptions/Join.visible = false

func _on_start_pressed() -> void:
	Global.start_game.emit()
	
func _on_online_pressed() -> void:
	$CenterContainer/VBoxContainer/MenuOptions/Local.visible = false
	$CenterContainer/VBoxContainer/MenuOptions/Online.visible = false
	$CenterContainer/VBoxContainer/MenuOptions/Host.visible = true
	$CenterContainer/VBoxContainer/MenuOptions/Join.visible = true
	Global.multiplayer_enabled = true
	
func _on_host_pressed() -> void:
	NetworkHandler.start_server()

func _on_join_pressed() -> void:
	NetworkHandler.start_client()
