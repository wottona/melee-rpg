# Path: /Users/andrewwotton/melee-rpg/Hitbox.gd
extends Area2D

@export var damage: int = 25

func _ready() -> void:
	monitoring = true
	monitorable = true
	
	# Connect local signal to self to verify raw engine collision mechanics
	area_entered.connect(_on_area_entered)
	print_debug("[Diagnostic] Hitbox initialized. Damage value: %d" % damage)

func _on_area_entered(incoming_area: Area2D) -> void:
	print_debug("[Diagnostic-Hitbox] RAW ENGINE INTERSECTION DETECTED! Overlapped with area named: '%s'" % incoming_area.name)
	
	# Fire global event pipeline
	print_debug("[Diagnostic-Hitbox] Emitting hit_registered to EventBus. Target: %s, Damage: %d" % [incoming_area.name, damage])
	EventBus.hit_registered.emit(incoming_area, damage, false)
