extends Node

# Global Game Flow
signal game_started
signal game_over(reason: String)

# RPG Combat & Statistics
signal hit_registered(target: Node2D, damage: int, critical: bool)
signal player_health_changed(current: int, max_health: int)
signal combo_triggered(count: int)
