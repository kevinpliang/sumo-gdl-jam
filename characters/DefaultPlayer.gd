extends KinematicBody2D

# child nodes
onready var sprite = $AnimatedSprite

# sfx
var push_sfx = load("res://resources/sfx/grunt1.wav")
var hit_sfx = load("res://resources/sfx/ouchu_quick.wav")

# motion variables
var vel = Vector2.ZERO
var speed = 25
var knockback = 100

# states
var current_state
enum STATES { IDLE, WALK, PUSH, HURT}
var facing
enum FACING { UP, DOWN }
var hit_from
enum HITFROM {ABOVE, BELOW, NOT}
# states during which you cannot control your character
var busy_states = [STATES.PUSH, STATES.HURT]

export var id = "p1"
# input keys..must be changed manually based on player
export var up = "p1_up"
export var left = "p1_left"
export var down = "p1_down"
export var right = "p1_right"
export var a = "p1_a"

func _ready():
	current_state = STATES.IDLE
	# weird hack to make players face correct direction
	yield(get_tree().create_timer(0.01), "timeout")
	if (id == "p1"):
		facing = FACING.UP
	else:
		facing = FACING.DOWN

func _process(_delta):
	#print(current_state)
	if !(current_state in busy_states):
		state_from_input(_delta)
	motion_from_state()
	sprite_from_state()

# Gets state based on input
func state_from_input(_delta):
	if (Input.is_action_just_pressed(a)):
		current_state = STATES.PUSH
	elif (Input.is_action_pressed(right) or Input.is_action_pressed (left) or Input.is_action_pressed(up) or Input.is_action_pressed(down)):
		current_state = STATES.WALK
		if (Input.is_action_pressed(up)):
			facing = FACING.UP
		elif (Input.is_action_pressed(down)):
			facing = FACING.DOWN
	else:
		current_state = STATES.IDLE

# Gets motion based on state
func motion_from_state():
	var motion = Vector2(0,0)	
	if (current_state == STATES.WALK):
		vel.x = int(Input.is_action_pressed(right)) - int(Input.is_action_pressed(left))
		vel.y = (int(Input.is_action_pressed(down)) - int(Input.is_action_pressed(up))) / float(2)
		motion = vel.normalized() * speed
		move_and_slide(motion)
	elif (current_state == STATES.PUSH):
		vel = Vector2.ZERO
		if ($PushTimer.is_stopped()):
			push()
	elif (current_state == STATES.HURT):
		motion.x = 0
		if (hit_from == HITFROM.ABOVE):
			motion.y = knockback
		elif (hit_from == HITFROM.BELOW):
			motion.y = -knockback
		else:
			print("Error: Invalid hit_from!")
		
	elif (current_state == STATES.IDLE):
		vel = Vector2.ZERO		
	move_and_slide(motion)
	
# Gets animation based on state
func sprite_from_state():
	if (vel.x > 0):
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	
	if (current_state == STATES.WALK):
		if (facing == FACING.UP):
			sprite.play("walk_up")
		elif (facing == FACING.DOWN):
			sprite.play("walk_down")
	if (current_state == STATES.PUSH):
		if (facing == FACING.UP):
			sprite.play("push_up")
		elif (facing == FACING.DOWN):
			sprite.play("push_down")
	elif (current_state == STATES.IDLE):
		if (facing == FACING.UP):
			sprite.play("idle_up")
		elif (facing == FACING.DOWN):
			sprite.play("idle_down")
		else:
			pass

# Player push
func push():
	$SFXPlayer.stream = push_sfx
	$SFXPlayer.play()
	$PushTimer.start()
	yield(get_tree().create_timer(0.6), "timeout")
	$PushHitBox/Shape.disabled = false
	yield(get_tree().create_timer(0.2), "timeout")
	$PushHitBox/Shape.disabled = true

# When hit by a push
func on_hit(from):
	$SFXPlayer.stream = hit_sfx
	$SFXPlayer.play()
	hit_from = from
	$HurtTimer.start()

# When Push Timer ends
func _on_PushTimer_timeout():
	if (current_state != STATES.HURT):
		current_state = STATES.IDLE

# When Hurt Timer ends
func _on_HurtTimer_timeout():
	hit_from = HITFROM.NOT
	current_state = STATES.IDLE

# When an Area2D enters this joint
func _on_HitBox_area_entered(area):
	# if the area2d is a push but is not one of my children (my own push)
	if (area.is_in_group("push") and !(area in get_children())):
		current_state = STATES.HURT
		
		# if the push is from below me
		if (area.get_parent().global_position.y > global_position.y):
			on_hit(HITFROM.BELOW)
			
		# if the push is from above me
		else:
			on_hit(HITFROM.ABOVE)


