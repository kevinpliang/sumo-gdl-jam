extends StaticBody2D

func _on_bounds_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		var player_id = area.get_parent().id

		if Global.multiplayer_enabled:
			if multiplayer.is_server():
				Global.emit_signal("player_oob", player_id)
		else:
			Global.emit_signal("player_oob", player_id)
