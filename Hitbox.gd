extends Area2D
class_name Hitbox

@export var damage: int = 15
@export var is_critical: bool = false

func _ready() -> void:
	# Ensure the hitbox doesn't accidentally check things on its own
	monitoring = true
	monitorable = false
	
