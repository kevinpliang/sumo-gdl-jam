extends Node

var main = null
var player_id = null
var player1 = null
var player2 = null
var p1score = 0
var p2score = 0

# signal if player leaves boundaries
signal player_oob(player_id)
signal start_game()

var curr_gamestate
enum GAMESTATE {PLAYING, WON, MENU}

var multiplayer_enabled = false

# should the tutorial be shown
var firstTime = true

func _ready():
	pass 

func _process(_delta):
	pass

func instance_node(node, parent):
	var node_instance = node.instantiate()
	parent.add_child(node_instance)
	return node_instance

func instance_node_at(node, location, parent):
	var node_instance = node.instantiate()
	parent.add_child(node_instance, true)
	node_instance.global_position = location
	return node_instance
