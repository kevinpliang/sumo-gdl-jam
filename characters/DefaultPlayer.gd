extends CharacterBody2D

# child nodes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# sfx
var push_sfx: AudioStream = preload("res://resources/sfx/grunt1.wav")
var hit_sfx: AudioStream = preload("res://resources/sfx/ouchu_quick.wav")

# motion variables
var vel: Vector2 = Vector2.ZERO
@export var speed: float = 25.0
@export var knockback: float = 100.0

# states
enum STATES { IDLE, WALK, PUSH, HURT }
@export var current_state: int = STATES.IDLE

enum FACING { UP, DOWN }
var facing: int = FACING.UP

enum HITFROM { ABOVE, BELOW, NOT }
var hit_from: int = HITFROM.NOT

# states during which you cannot control your character
var busy_states: Array = [STATES.PUSH, STATES.HURT]

# input
@export var id: String = "p1"
@export var up: String = "p1_up"
@export var left: String = "p1_left"
@export var down: String = "p1_down"
@export var right: String = "p1_right"
@export var a: String = "p1_a"

func _ready() -> void:
	current_state = STATES.IDLE
	# make players face correct direction after one frame
	await get_tree().create_timer(0.01).timeout
	if id == "p1":
		facing = FACING.UP
	else:
		facing = FACING.DOWN
		
	if Global.multiplayer_enabled:
		set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	
	if Global.multiplayer_enabled and !is_multiplayer_authority():
		return
	
	if current_state not in busy_states and Global.curr_gamestate == Global.GAMESTATE.PLAYING:
		state_from_input(delta)
	motion_from_state(delta)
	sprite_from_state()

# Gets state based on input
func state_from_input(_delta: float) -> void:
	if Input.is_action_just_pressed(a) and $PushTimer.is_stopped():
		current_state = STATES.PUSH
		push()
	elif (
		Input.is_action_pressed(right)
		or Input.is_action_pressed(left)
		or Input.is_action_pressed(up)
		or Input.is_action_pressed(down)
	):
		current_state = STATES.WALK
		if Input.is_action_pressed(up):
			facing = FACING.UP
		elif Input.is_action_pressed(down):
			facing = FACING.DOWN
	else:
		current_state = STATES.IDLE


# Gets motion based on state
func motion_from_state(delta: float) -> void:
	var motion := Vector2.ZERO

	if current_state == STATES.WALK:
		vel.x = int(Input.is_action_pressed(right)) - int(Input.is_action_pressed(left))
		vel.y = (int(Input.is_action_pressed(down)) - int(Input.is_action_pressed(up))) / 2.0
		motion = vel.normalized() * speed
		velocity = motion
		move_and_collide(velocity*delta)
	elif current_state == STATES.PUSH:
		vel = Vector2.ZERO
	elif current_state == STATES.HURT:
		motion.x = 0
		if hit_from == HITFROM.ABOVE:
			motion.y = knockback
		elif hit_from == HITFROM.BELOW:
			motion.y = -knockback
		else:
			push_error("Invalid hit_from!")
	elif current_state == STATES.IDLE:
		vel = Vector2.ZERO

	velocity = motion
	move_and_slide()

# Gets animation based on state
func sprite_from_state() -> void:
	sprite.flip_h = vel.x < 0

	match current_state:
		STATES.WALK:
			if facing == FACING.UP:
				sprite.play("walk_up")
			elif facing == FACING.DOWN:
				sprite.play("walk_down")
		STATES.PUSH:
			if facing == FACING.UP:
				sprite.play("push_up")
			elif facing == FACING.DOWN:
				sprite.play("push_down")
		STATES.IDLE:
			if facing == FACING.UP:
				sprite.play("idle_up")
			elif facing == FACING.DOWN:
				sprite.play("idle_down")

# Player push
func push() -> void:
	var sfx_player: AudioStreamPlayer = $SFXPlayer
	sfx_player.stream = push_sfx
	sfx_player.play()

	$PushTimer.start()

	await get_tree().create_timer(0.6).timeout
	if facing == FACING.UP:
		$PushUpHitBox/CollisionShape2D.disabled = false
	else:
		$PushHitBox/CollisionShape2D.disabled = false

	await get_tree().create_timer(0.2).timeout
	$PushUpHitBox/CollisionShape2D.disabled = true
	$PushHitBox/CollisionShape2D.disabled = true

# When hit by a push
@rpc("any_peer", "call_local")
func on_hit(from: int) -> void:
	var sfx_player: AudioStreamPlayer = $SFXPlayer
	sfx_player.stream = hit_sfx
	sfx_player.play()
	
	hit_from = from
	current_state = STATES.HURT
	$HurtTimer.start()

# When Push Timer ends
func _on_push_timer_timeout() -> void:
	if current_state != STATES.HURT:
		current_state = STATES.IDLE

# When Hurt Timer ends
func _on_hurt_timer_timeout() -> void:
	hit_from = HITFROM.NOT
	current_state = STATES.IDLE

# When an Area2D enters this hitbox
func _on_hit_box_area_entered(area: Area2D) -> void:
	# if the area2d is a push but not my own
	if area.is_in_group("push") and area not in get_children():
		current_state = STATES.HURT

		# if the push is from below me
		var from_dir = HITFROM.NOT
		if area.get_parent().global_position.y > global_position.y:
			from_dir = HITFROM.BELOW
		else:
			from_dir = HITFROM.ABOVE
		
		rpc_id(get_multiplayer_authority(), "on_hit", from_dir)
		
func _is_oob() -> bool:
	return false
