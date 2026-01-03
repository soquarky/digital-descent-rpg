extends Node

## Central game state management

enum GameState {
	MAIN_MENU,
	PLAYING,
	COMBAT,
	DIALOGUE,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.MAIN_MENU
var current_scene_path: String = ""
var checkpoint_scene: String = ""
var checkpoint_data: Dictionary = {}

signal state_changed(new_state: GameState)
signal scene_transition_started(from_scene: String, to_scene: String)
signal scene_transition_completed(scene_path: String)
signal checkpoint_saved(checkpoint_name: String)

func _ready():
	print("[GameManager] Initialized")

func change_game_state(new_state: GameState):
	"""Change the current game state"""
	var old_state = current_state
	current_state = new_state
	state_changed.emit(new_state)
	print("[GameManager] State: ", _state_to_string(old_state), " -> ", _state_to_string(new_state))
	
	# Handle state-specific logic
	match new_state:
		GameState.PAUSED:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false
		GameState.COMBAT:
			get_tree().paused = false
		GameState.GAME_OVER:
			get_tree().paused = true

func change_scene(scene_path: String):
	"""Transition to a new scene"""
	var from_scene = current_scene_path
	scene_transition_started.emit(from_scene, scene_path)
	
	var result = get_tree().change_scene_to_file(scene_path)
	if result == OK:
		current_scene_path = scene_path
		scene_transition_completed.emit(scene_path)
		print("[GameManager] Scene changed to: ", scene_path)
	else:
		print("[ERROR] Failed to change scene to: ", scene_path)

func save_checkpoint(checkpoint_name: String):
	"""Save current game state as checkpoint"""
	checkpoint_scene = current_scene_path
	checkpoint_data = {
		"health": PlayerData.health,
		"hyperthymesia": PlayerData.hyperthymesia_integrity,
		"memory_fragments": PlayerData.memory_fragments.duplicate(),
		"circles_completed": PlayerData.circles_completed,
		"current_circle": PlayerData.current_circle,
		"neural_pathways": PlayerData.neural_pathways.duplicate()
	}
	checkpoint_saved.emit(checkpoint_name)
	print("[GameManager] Checkpoint saved: ", checkpoint_name)

func load_checkpoint():
	"""Restore from last checkpoint"""
	if checkpoint_scene.is_empty():
		print("[WARNING] No checkpoint to load")
		return
	
	# Restore player data
	PlayerData.health = checkpoint_data.get("health", 100.0)
	PlayerData.hyperthymesia_integrity = checkpoint_data.get("hyperthymesia", 100.0)
	PlayerData.memory_fragments = checkpoint_data.get("memory_fragments", [])
	PlayerData.circles_completed = checkpoint_data.get("circles_completed", 0)
	PlayerData.current_circle = checkpoint_data.get("current_circle", 1)
	PlayerData.neural_pathways = checkpoint_data.get("neural_pathways", {})
	
	# Return to checkpoint scene
	change_scene(checkpoint_scene)
	print("[GameManager] Checkpoint loaded")

func game_over():
	"""Handle player death/failure"""
	change_game_state(GameState.GAME_OVER)
	# Show game over screen with option to load checkpoint

func _state_to_string(state: GameState) -> String:
	match state:
		GameState.MAIN_MENU: return "MAIN_MENU"
		GameState.PLAYING: return "PLAYING"
		GameState.COMBAT: return "COMBAT"
		GameState.DIALOGUE: return "DIALOGUE"
		GameState.PAUSED: return "PAUSED"
		GameState.GAME_OVER: return "GAME_OVER"
		_: return "UNKNOWN"

func _input(event):
	# Global pause toggle
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			change_game_state(GameState.PAUSED)
		elif current_state == GameState.PAUSED:
			change_game_state(GameState.PLAYING)