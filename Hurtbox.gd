extends Area2D
class_name Hurtbox

func _ready() -> void:
	monitoring = false
	monitorable= true
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		print("Ouch! Taken ", hitbox.damage, " damage.")
		
		# Broadcast the hit globally through yesterday's Event Bus!
		EventBus.hit_registered.emit(owner, hitbox.damage, hitbox.is_critical)
