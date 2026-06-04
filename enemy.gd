# Path: /Users/andrewwotton/melee-rpg/EnemyHealth.gd
extends CharacterBody2D

@export var max_health: int = 100
@onready var current_health: int = max_health
@onready var visual_sprite: Sprite2D = $Visual

var is_flashing: bool = false

func _ready() -> void:
	# Verify required nodes exist in the hierarchy to prevent runtime crashes
	assert(visual_sprite != null, "Error: 'Visual' Sprite2D node not found as a direct child of Enemy.")
	
	# Connect to the EventBus to listen for globally registered hits
	EventBus.hit_registered.connect(_on_global_hit_registered)

## Processes incoming damage and handles death conditions
func take_damage(amount: int) -> void:
	current_health -= amount
	print_debug("[Combat] Enemy took %d damage. Current Health: %d/%d" % [amount, current_health, max_health])
	
	if current_health > 0:
		trigger_impact_flash()
	else:
		execute_death()

## Triggers the non-blocking 0.9-second red impact flash
func trigger_impact_flash() -> void:
	if is_flashing:
		return # Prevent overlapping flash timers from disrupting the sequence
	
	is_flashing = true
	visual_sprite.modulate = Color(1.0, 0.0, 0.0, 1.0) # Pure red
	
	# Create a non-blocking scene timer for exactly 0.9 seconds
	await get_tree().create_timer(0.9).timeout
	
	# Safely restore original visual state if the node still exists
	if is_instance_valid(visual_sprite):
		visual_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0) # Normal rendering
	is_flashing = false

## Handles the cleanup of the enemy entity when health reaches zero
func execute_death() -> void:
	print_debug("[Combat] Enemy health depleted. Executing queue_free().")
	# Disconnect from EventBus to prevent memory leaks during the frame teardown
	if EventBus.hit_registered.is_connected(_on_global_hit_registered):
		EventBus.hit_registered.disconnect(_on_global_hit_registered)
	queue_free()

## Callback from EventBus to verify if this specific instance was the targeted victim
func _on_global_hit_registered(target: Node, damage: int, is_critical: bool) -> void:
	# Target validation: Check if the targeted node is this specific Enemy instance
	# or if the targeted node is our child Hurtbox
	if target == self or target == $Hurtbox:
		take_damage(damage)

## Engine Signal Callback from child Hurtbox (Area2D) when another Area2D enters it
func _on_hurtbox_area_entered(area: Area2D) -> void:
	# Verify that the invading area is a valid Hitbox containing damage data
	if area.get("damage") != null:
		var incoming_damage = area.get("damage")
		print_debug("[Collision] Hitbox detected! Exposing hit to EventBus. Target: %s, Damage: %d" % [self.name, incoming_damage])
		
		# Fire the global signal via the Autoload Singleton
		EventBus.hit_registered.emit(self, incoming_damage, false)
