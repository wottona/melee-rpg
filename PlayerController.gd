extends CharacterBody2D

# Movement configuration
@export var speed: float = 200.0

# Node references - Adjust paths if your names differ exactly
@onready var player_hitbox: Area2D = $PlayerHitbox
@onready var hitbox_collision: CollisionShape2D = $PlayerHitbox/CollisionShape2D

# Simple state tracking
var is_attacking: bool = false
var attack_duration: float = 0.2
var attack_timer: float = 0.0

func _ready() -> void:
	# Ensure the hitbox is strictly disabled when the game starts
	if hitbox_collision:
		hitbox_collision.disabled = true
	else:
		push_error("PlayerController: CollisionShape2D not found under PlayerHitbox!")

func _physics_process(delta: float) -> void:
	if is_attacking:
		_handle_attack_state(delta)
	else:
		_handle_movement_state()

## Handles player movement when not locked in an attack animation/state
func _handle_movement_state() -> void:
	# Updated to match your custom Input Map actions
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		# Explicitly normalize to guarantee consistent diagonal speed
		velocity = direction.normalized() * speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, speed)
		
	move_and_slide()
	
	# Check for attack trigger
	if Input.is_action_just_pressed("attack"):
		_start_attack()

## Initiates the attack state and opens the hitbox window
func _start_attack() -> void:
	is_attacking = true
	attack_timer = attack_duration
	velocity = Vector2.ZERO # Halt movement during the attack swing
	
	if hitbox_collision:
		hitbox_collision.disabled = false

## Tracks the attack window duration and closes it upon expiration
func _handle_attack_state(delta: float) -> void:
	attack_timer -= delta
	if attack_timer <= 0.0:
		_end_attack()

## Resets the player back to the movement state and disables the hitbox
func _end_attack() -> void:
	is_attacking = false
	if hitbox_collision:
		hitbox_collision.disabled = true
