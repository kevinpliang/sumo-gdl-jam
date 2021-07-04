extends Node

var curr_gamestate
enum GAMESTATE {PLAYING, WON}

onready var DefaultStage = preload("res://environments/DefaultStage.tscn")
onready var DefaultPlayer = preload("res://characters/DefaultPlayer.tscn")

func _ready():
	Global.main = self
	# OS.window_maximized = true
	
	# startup
	Global.connect("player_oob", self, "on_player_oob")
	curr_gamestate = GAMESTATE.PLAYING
	
	Global.instance_node(DefaultStage, self)
	var player1 = Global.instance_node_at(DefaultPlayer, Vector2(64, 64), $YSort)
	var player2 = Global.instance_node_at(DefaultPlayer, Vector2(64, 42), $YSort)
	
	# player 2's inputs must be changed
	player2.id = "p2"
	player2.up = "p2_up"
	player2.left = "p2_left"
	player2.down = "p2_down"
	player2.right = "p2_right"
	player2.a = "p2_a"
	

func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("enter"):
		if (curr_gamestate == GAMESTATE.WON):
			get_tree().reload_current_scene()

# when player_oob signal is received from stage
func on_player_oob(player_id):
	if (curr_gamestate != GAMESTATE.WON):
		if (player_id == "p1"):
			$UI/Label.set_text("Player 2 Wins!\n[Enter] to restart")
		elif (player_id == "p2"):
			$UI/Label.set_text("Player 1 Wins!\n[Enter] to restart")
		else:
			print("Error: Invalid Player ID given by player_oob!")
		curr_gamestate = GAMESTATE.WON
