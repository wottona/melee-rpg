# ==========================================
# Hurtbox.gd
# Unified component for handling health metrics and damage flash visuals.
# ==========================================
extends Area2D

signal health_changed(current_health: int, max_health: int)
signal enemy_died

@export var max_health: int = 100
@onready var current_health: int = max_health

func _ready() -> void:
	# Ensure monitorable is false; Hurtboxes only detect, they aren't detected by other hurtboxes
	monitorable = false
	# Connect the internal Area2D signal to detect incoming Hitboxes
	area_entered.connect(_on_area_entered)

func _on_area_entered(incoming_area: Area2D) -> void:
	# Duck-typing verification: check if the area contains a damage value directly
	if incoming_area.get("damage") != null:
		take_damage(incoming_area.damage)

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return # Already dead, ignore subsequent frames
		
	current_health = clamp(current_health - amount, 0, max_health)
	health_changed.emit(current_health, max_health)
	
	# Broadcast damage event globally via the EventBus
	EventBus.hit_registered.emit(get_parent(), amount, false)
	
	# Trigger the visual flash feedback
	flash_red_feedback()
	
	if current_health <= 0:
		die()

func flash_red_feedback() -> void:
	print("🚨 SUCCESS: PHYSICS COLLISION REGISTERED!")
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			# Target anything that can hold a visual texture
			if child is Sprite2D:
				# Force both modulation layers to bright red
				child.modulate = Color.RED
				child.self_modulate = Color.RED
				
				# Force Godot to immediately redraw this object on the screen
				child.queue_redraw()
				
				# Wait 0.9 seconds
				await get_tree().create_timer(0.9).timeout
				
				# If the enemy died during the timer, prevent running code on a deleted node
				if is_instance_valid(child):
					# Force both layers completely back to clean white
					child.modulate = Color.WHITE
					child.self_modulate = Color.WHITE
					child.queue_redraw()

func die() -> void:
	enemy_died.emit()
	# Clean up the parent Enemy node from the tree safely
	get_parent().queue_free()
