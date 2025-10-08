extends Node

@onready var Menu: PackedScene = preload("res://game/Menu.tscn")
@onready var Tutorial: PackedScene = preload("res://game/Tutorial.tscn")
@onready var DefaultStage: PackedScene = preload("res://environments/DefaultStage.tscn")
@onready var DefaultPlayer: PackedScene = preload("res://characters/DefaultPlayer.tscn")

# instances that require global scope
var menuInstance: Node = null
var stageInstance: Node = null
var tutorialInstance: Node = null

# music
var win_music: AudioStream = preload("res://resources/music/summo_v2.ogg")
var playing_music: AudioStream = preload("res://resources/music/roundv2.ogg")
var menu_music: AudioStream = preload("res://resources/music/destrpyhim.ogg")


func _ready() -> void:
	Global.main = self
	Global.curr_gamestate = Global.GAMESTATE.MENU

	# signals
	Global.start_game.connect(_on_start_game)
	Global.player_oob.connect(on_player_oob)
	multiplayer.peer_connected.connect(_on_start_online_game)
	
	menuInstance = Global.instance_node(Menu, self)

	# menu music
	$Music.stream = menu_music
	$Music.play()

	# add people
	stageInstance = Global.instance_node(DefaultStage, self)
	$Node2D.y_sort_enabled = true
	
	# hide people
	$UI/p1ScoreLabel.visible = false
	$UI/p2ScoreLabel.visible = false
	stageInstance.visible = false

func _process(_delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("enter"):
		if (Global.curr_gamestate == Global.GAMESTATE.WON):
			if !Global.multiplayer_enabled:
				_on_start_game()
			else:
				_on_start_online_game(0)


func _on_start_game() -> void:
	menuInstance.visible = false
	$UI/VictoryLabel.text = ""
	$UI/p1ScoreLabel.visible = true
	$UI/p2ScoreLabel.visible = true

	# tutorial
	if Global.firstTime:
		tutorialInstance = Global.instance_node_at(Tutorial, Vector2(64, 64), self)

	# stage & players
	if Global.player1 == null:
		Global.player1 = Global.instance_node_at(DefaultPlayer, Vector2(64, 64), $Node2D)
	if Global.player2 == null:
		Global.player2 = Global.instance_node_at(DefaultPlayer, Vector2(64, 42), $Node2D)
	Global.player1.visible = true
	Global.player2.visible = true
	stageInstance.visible = true
	
	# player 2 inputs
	Global.player2.id = "p2"
	Global.player2.up = "p2_up"
	Global.player2.left = "p2_left"
	Global.player2.down = "p2_down"
	Global.player2.right = "p2_right"
	Global.player2.a = "p2_a"

	Global.player1.position = Vector2(64, 64)
	Global.player2.position = Vector2(64, 42)

	Global.curr_gamestate = Global.GAMESTATE.PLAYING

	$Music.stream = playing_music
	$Music.play()
	
func _on_start_online_game(_id: int) -> void:
	menuInstance.visible = false
	$UI/VictoryLabel.text = ""
	$UI/p1ScoreLabel.visible = true
	$UI/p2ScoreLabel.visible = true

	# stage
	stageInstance.visible = true
	
	if Global.player1 != null:
		Global.player1.position = Vector2(64, 64)
	if Global.player2 != null:
		Global.player2.position = Vector2(64, 42)

	Global.curr_gamestate = Global.GAMESTATE.PLAYING

	$Music.stream = playing_music
	$Music.play()
	
@rpc("any_peer", "call_local")
func declare_winner(player_id: String) -> void:
	print(player_id)
	
	if tutorialInstance:
		tutorialInstance.visible = false
		Global.firstTime = false

	if Global.curr_gamestate != Global.GAMESTATE.WON:
		match player_id:
			"p1":
				$UI/VictoryLabel.text = "Player 2 Wins!\n[Enter] to restart"
				Global.p2score += 1
				$UI/p2ScoreLabel.text = str(Global.p2score)
			"p2":
				$UI/VictoryLabel.text = "Player 1 Wins!\n[Enter] to restart"
				Global.p1score += 1
				$UI/p1ScoreLabel.text = str(Global.p1score)
			_:
				push_warning("Invalid Player ID given by player_oob!")

		Global.curr_gamestate = Global.GAMESTATE.WON
		$Music.stream = win_music
		$Music.play()


func on_player_oob(player_id: String) -> void:
	if Global.multiplayer_enabled:
		if multiplayer.is_server():
			rpc("declare_winner", player_id)
	else:
		declare_winner(player_id)
