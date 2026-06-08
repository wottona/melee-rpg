extends CharacterBody2D

# --- Export Variables (Adjustable in the Inspector) ---
@export var movement_speed: float = 150.0
@export var hitbox_offset_distance: float = 50.0
@export var attack_duration: float = 0.2

# --- State Variables ---
var is_attacking: bool = false
var attack_timer: float = 0.0
var last_facing_direction: Vector2 = Vector2.DOWN # Default facing downwards

# --- Onready Nodes ---
@onready var visual_sprite: Sprite2D = $Visual
@onready var player_hitbox: Area2D = $PlayerHitbox
@onready var hitbox_collision: CollisionShape2D = $PlayerHitbox/CollisionShape2D
@onready var swing_visual: Node2D = $PlayerHitbox/SwingVisual # Works for ColorRect or Line2D

func _ready() -> void:
	# Ensure everything starts hidden and disabled when the game boots
	if hitbox_collision:
		hitbox_collision.disabled = true
	if swing_visual:
		swing_visual.hide()
	
	# Initial position setup
	_update_hitbox_position()

func _physics_process(delta: float) -> void:
	# 1. Input detection runs CONSTANTLY so your character never forgets where it's looking
	var input_direction := Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# If moving, normalize the vector and save it
	if input_direction != Vector2.ZERO:
		last_facing_direction = input_direction.normalized()
		_update_hitbox_position()

	# 2. State Machine Loop
	if is_attacking:
		# Count down the timer using the physics frame delta
		attack_timer -= delta
		if attack_timer <= 0.0:
			_end_attack()
	else:
		# Attack button listener (using standard ui_accept/Space as default trigger)
		if Input.is_action_just_pressed("ui_accept"):
			_start_attack()
		else:
			# Normal movement processing
			velocity = input_direction * movement_speed
			move_and_slide()

## Recalculates the hitbox position out in front of the player
func _update_hitbox_position() -> void:
	if player_hitbox:
		player_hitbox.position = last_facing_direction * hitbox_offset_distance

## Initiates the attack sequence, opens up the hitbox, and shows the visual marker
func _start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	velocity = Vector2.ZERO # Freeze the character in place during the swing
	
	if hitbox_collision:
		hitbox_collision.disabled = false
	if swing_visual:
		swing_visual.show()

## Cleans up the attack state and hides the visual systems
func _end_attack() -> void:
	is_attacking = false
	
	if hitbox_collision:
		hitbox_collision.disabled = true
	if swing_visual:
		swing_visual.hide()
