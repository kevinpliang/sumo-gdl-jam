extends StaticBody2D

func _ready():
	pass

func _on_Bounds_area_exited(area):
	if (area.is_in_group("player")):
		Global.emit_signal("player_oob", area.get_parent().id)
