extends MultiplayerSpawner

@export var network_player: PackedScene

var player_slots = {}

func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int):
	if !multiplayer.is_server():
		return

	var player: Node = network_player.instantiate()
	player.name = str(id)
	
	if Global.player1 == null:
		Global.player1 = player
		Global.player1.position = Vector2(64, 64)
		print(player.id)
		print(Global.player1.id)
		print("SET PLAYER 1")
	elif Global.player2 == null:
		Global.player2 = player
		Global.player2.id = "p2"
		Global.player2.position = Vector2(64, 42)
		print(player.id)
		print(Global.player2.id)
		print("SET PLAYER 2")
	
	get_node(spawn_path).add_child.call_deferred(player, true)
 	
			
