extends Node

var main = null
var player = null

# signal if player leaves boundaries
signal player_oob(player_id)

func _ready():
	pass 

func _process(_delta):
	pass

func instance_node(node, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

func instance_node_at(node, location, parent):
	var node_instance = node.instance()
	parent.add_child(node_instance)
	node_instance.global_position = location
	return node_instance
