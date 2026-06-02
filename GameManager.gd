extends Node

enum GameState { MAIN_MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MAIN_MENU

func _ready() -> void:
	EventBus.game_started.connect(_on_game_started)

func change_state(new_state: GameState) -> void:
	current_state = new_state
	print("State changed to: ", GameState.keys()[new_state])

func _on_game_started() -> void:
	change_state(GameState.PLAYING)
