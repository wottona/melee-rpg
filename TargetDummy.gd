extends Node2D

func _ready() -> void:
	# Connect to the global EventBus to listen for hits
	EventBus.hit_registered.connect(_on_global_hit_registered)
	
func _on_global_hit_registered(target: Node2D, damage: int, critical: bool) -> void:
	# Check if THIS specific dummy instance was the one hit
	if target == self:
		print("Dummy recieved signal confirmation for: ", damage)
		_trigger_visual_flash()
		
func _trigger_visual_flash() -> void:
	# Temorarlily tint the dummy red to visually confirm the hit worked
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
