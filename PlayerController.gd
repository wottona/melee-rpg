# /Users/andrewwotton/melee-rpg/PlayerController.gd
extends CharacterBody2D

## Engine configuration for top-down 4-way kinematic movement.
## Handles normalized diagonal velocity to prevent speed compounding.

@export_category("Movement Attributes")
@export var movement_speed: float = 300.0
@export var friction: float = 0.25

func _physics_process(_delta: float) -> void:
	_handle_movement_input()

func _handle_movement_input() -> void:
	var input_direction: Vector2 = Vector2.ZERO

	# Read concrete input values from the configured Input Map
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Prevent diagonal movement from being faster than straight movement
	if input_direction.length() > 0.0:
		input_direction = input_direction.normalized()
		# Direct velocity calculation via vector multiplication
		velocity = input_direction * movement_speed
	else:
		# Apply smooth deceleration when no keys are pressed
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed * friction)
		
	# Execute frame-rate independent physics translation
	move_and_slide()
