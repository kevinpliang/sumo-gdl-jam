extends StaticBody2D

func _ready() -> void:
	pass

func _on_bounds_area_exited(area: Area2D) -> void:
	if area.is_in_group("player"):
		Global.emit_signal("player_oob", area.get_parent().id)
