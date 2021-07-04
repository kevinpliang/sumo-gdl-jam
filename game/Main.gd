extends Node

onready var Menu = preload("res://game/Menu.tscn")
onready var Tutorial = preload("res://game/Tutorial.tscn")
onready var DefaultStage = preload("res://environments/DefaultStage.tscn")
onready var DefaultPlayer = preload("res://characters/DefaultPlayer.tscn")


# instances that require global scope
var menuInstance = null
var stageInstance = null
var tutorialInstance = null

# music
var win_music = load("res://resources/music/summo_v2.ogg")
var playing_music = load("res://resources/music/roundv2.ogg")
var menu_music = load("res://resources/music/destory_him.ogg")

func _ready():
	Global.main = self
	# OS.window_maximized = true

	Global.connect("player_oob", self, "on_player_oob")
	Global.curr_gamestate = Global.GAMESTATE.MENU
	menuInstance = Global.instance_node(Menu, self)
	
	# menu music
	$Music.stream = menu_music
	$Music.play()
	
	# add people
	stageInstance = Global.instance_node(DefaultStage, self)
	Global.player1 = Global.instance_node_at(DefaultPlayer, Vector2(64, 64), $YSort)
	Global.player2 = Global.instance_node_at(DefaultPlayer, Vector2(64, 42), $YSort)
	
	# player 2's inputs must be changed
	Global.player2.id = "p2"
	Global.player2.up = "p2_up"
	Global.player2.left = "p2_left"
	Global.player2.down = "p2_down"
	Global.player2.right = "p2_right"
	Global.player2.a = "p2_a"
	
func _process(_delta):
	pass

func _input(event):
	if event.is_action_pressed("enter"):
		if (Global.curr_gamestate == Global.GAMESTATE.WON):
			start_game()
		elif (Global.curr_gamestate == Global.GAMESTATE.MENU):
			start_game()

func start_game():
	# hide menu and UI
	menuInstance.visible = false
	$UI/VictoryLabel.set_text("")
	$UI/p1ScoreLabel.visible = true
	$UI/p2ScoreLabel.visible = true
	
	# show tutorial if first time
	if (Global.firstTime):
		tutorialInstance = Global.instance_node_at(Tutorial, Vector2(64,64), self)

	# show stage and players
	Global.player1.visible = true
	Global.player2.visible = true
	stageInstance.visible = true
	
	# move players to starting positions
	Global.player1.position = Vector2(64, 64)
	Global.player2.position = Vector2(64, 42)

	Global.curr_gamestate = Global.GAMESTATE.PLAYING
	
	$Music.stream = playing_music
	$Music.play()

# when player_oob signal is received from stage
func on_player_oob(player_id):
	if (tutorialInstance): 
		tutorialInstance.visible = false
		Global.firstTime = false
	if (Global.curr_gamestate != Global.GAMESTATE.WON):
		if (player_id == "p1"):
			$UI/VictoryLabel.set_text("Player 2 Wins!\n[Enter] to restart")
			Global.p2score+=1
			$UI/p2ScoreLabel.set_text(str(Global.p2score))
		elif (player_id == "p2"):
			$UI/VictoryLabel.set_text("Player 1 Wins!\n[Enter] to restart")
			Global.p1score+=1
			$UI/p1ScoreLabel.set_text(str(Global.p1score))
		else:
			print("Error: Invalid Player ID given by player_oob!")
		Global.curr_gamestate = Global.GAMESTATE.WON
		$Music.stream = win_music
		$Music.play()
