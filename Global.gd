extends Node

var main = null
var player1 = null
var player2 = null
var p1score = 0
var p2score = 0

# signal if player leaves boundaries
signal player_oob(player_id)

var curr_gamestate
enum GAMESTATE {PLAYING, WON, MENU}

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
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance
