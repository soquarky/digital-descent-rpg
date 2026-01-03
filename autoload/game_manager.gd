extends Node

# GameManager Singleton - Manages scene flow and game progression
signal game_started
signal circle_entered(circle: int)
signal circle_completed(circle: int)
signal game_over(reason: String)
signal boss_defeated(circle: int)
signal new_game_started

enum GameState { MENU, PLAYING, PAUSED, DIALOGUE, COMBAT, GAME_OVER }

var current_state: GameState = GameState.MENU
var is_paused: bool = false
var current_circle: int = 1
var scene_map: Dictionary = {
	1: "res://scenes/levels/circle_1_limbo.tscn",
	2: "res://scenes/levels/circle_2_lust.tscn",
	3: "res://scenes/levels/circle_3_gluttony.tscn",
	4: "res://scenes/levels/circle_4_greed.tscn",
	5: "res://scenes/levels/circle_5_wrath.tscn",
	6: "res://scenes/levels/circle_6_heresy.tscn",
	7: "res://scenes/levels/circle_7_violence.tscn",
	8: "res://scenes/levels/circle_8_fraud.tscn",
	9: "res://scenes/levels/circle_9_treachery.tscn",
}

var circle_bosses: Dictionary = {
	1: "Neutral Shade",
	2: "Siren of Desire",
	3: "Bloated Glutton",
	4: "Hoarder Shadow",
	5: "Rage Incarnate",
	6: "Heretic Prophet",
	7: "Murder Beast",
	8: "Master Deceiver",
	9: "Lucifer Himself",
}

func _ready():
	add_to_group("autoload")
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		if current_state == GameState.PLAYING:
			toggle_pause()

func start_new_game() -> bool:
	PlayerData._initialize_game()
	current_circle = 1
	current_state = GameState.PLAYING
	new_game_started.emit()
	game_started.emit()
	return load_circle(1)

func load_circle(circle: int) -> bool:
	if circle < 1 or circle > 9:
		return false
	
	if circle not in scene_map:
		push_error("No scene mapped for circle: " + str(circle))
		return false
	
	current_circle = circle
	PlayerData.current_circle = circle
	PlayerData.visit_circle(circle)
	
	# Load dialogue intro
	match circle:
		1:
			DialogueSystem.start_dialogue("limbo_complete" if PlayerData.circle_progress[1]["completed"] else "aria_welcome")
		2:
			DialogueSystem.start_dialogue("circle_2_intro")
		_:
			pass
	
	circle_entered.emit(circle)
	
	# Load scene
	var scene_path = scene_map[circle]
	get_tree().change_scene_to_file(scene_path)
	
	return true

func complete_circle(circle: int) -> bool:
	if circle not in PlayerData.circle_progress:
		return false
	
	PlayerData.complete_circle(circle)
	circle_completed.emit(circle)
	
	# Move to next circle
	if circle < 9:
		await get_tree().create_timer(2.0).timeout
		load_circle(circle + 1)
	else:
		# Game complete
		end_game("victory")
	
	return true

func trigger_boss_fight(circle: int):
	if circle not in circle_bosses:
		return
	
	var boss_name = circle_bosses[circle]
	var boss = CombatSystem.spawn_enemy(boss_name)
	if boss:
		CombatSystem.start_combat(boss)

func end_game(reason: String):
	current_state = GameState.GAME_OVER
	game_over.emit(reason)
	
	match reason:
		"victory":
			print("CONGRATULATIONS: You have conquered the Nine Circles!")
			print("You have escaped the digital descent.")
		"defeat":
			print("You have been conquered. The circles claim another soul.")
		"quit":
			print("You have abandoned your journey.")

	PlayerData.save_progress()

func toggle_pause():
	if current_state in [GameState.COMBAT, GameState.DIALOGUE]:
		return  # Can't pause during critical moments
	
	is_paused = !is_paused
	get_tree().paused = is_paused

# Progression Helpers
func get_circle_completion_percentage() -> float:
	var completed = 0
	for i in range(1, 10):
		if PlayerData.circle_progress[i]["completed"]:
			completed += 1
	return float(completed) / 9.0 * 100.0

func get_total_enemies_defeated() -> int:
	var total = 0
	for i in range(1, 10):
		total += PlayerData.circle_progress[i]["enemies_defeated"]
	return total

func get_current_circle_progress() -> float:
	var circle_data = PlayerData.circle_progress[current_circle]
	if circle_data["completed"]:
		return 100.0
	# Enemy-based scaling: 25% per enemy defeated (0-4 enemies typical per circle)
	return min(100.0, circle_data["enemies_defeated"] * 25.0)

func set_game_state(new_state: GameState):
	current_state = new_state
	
	match new_state:
		GameState.DIALOGUE:
			get_tree().paused = true
		GameState.COMBAT:
			get_tree().paused = true
		GameState.PLAYING:
			get_tree().paused = false

func get_save_exists() -> bool:
	return ResourceLoader.exists("user://saves/progress.json")

func load_saved_game() -> bool:
	if not get_save_exists():
		return false
	
	if PlayerData.load_progress():
		current_circle = PlayerData.current_circle
		current_state = GameState.PLAYING
		game_started.emit()
		return load_circle(current_circle)
	
	return false
