extends Node

# PlayerData Singleton - Manages all persistent player state
# Signals for state changes
signal state_changed(new_state: String)
signal health_changed(new_health: int)
signal memory_collected(memory: Dictionary)
signal circle_progressed(circle: int)

# Player State
var current_state: String = "adult"  # "adult" or "child"
var max_health: int = 100
var current_health: int = 100
var current_circle: int = 1
var circle_progress: Dictionary = {}

# Memory System
var memories: Array[Dictionary] = []
var equipped_memory: Dictionary = {}
var memory_types: Dictionary = {
	"joy": Color.YELLOW,
	"trauma": Color.RED,
	"regret": Color.BLUE,
	"desire": Color.MAGENTA,
	"anger": Color.DARK_RED,
	"hope": Color.GREEN,
	"despair": Color.BLACK
}

func _ready():
	add_to_group("autoload")
	_initialize_game()

func _initialize_game():
	current_state = "adult"
	current_health = max_health
	current_circle = 1
	circle_progress = {
		1: {"visited": true, "completed": false, "enemies_defeated": 0},
		2: {"visited": false, "completed": false, "enemies_defeated": 0},
		3: {"visited": false, "completed": false, "enemies_defeated": 0},
		4: {"visited": false, "completed": false, "enemies_defeated": 0},
		5: {"visited": false, "completed": false, "enemies_defeated": 0},
		6: {"visited": false, "completed": false, "enemies_defeated": 0},
		7: {"visited": false, "completed": false, "enemies_defeated": 0},
		8: {"visited": false, "completed": false, "enemies_defeated": 0},
		9: {"visited": false, "completed": false, "enemies_defeated": 0},
	}

# State Switching
func toggle_state():
	match current_state:
		"adult":
			current_state = "child"
		"child":
			current_state = "adult"
	state_changed.emit(current_state)

func is_adult_state() -> bool:
	return current_state == "adult"

func is_child_state() -> bool:
	return current_state == "child"

# Health Management
func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	health_changed.emit(current_health)
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health)

func die():
	print("Player died. Resetting to last checkpoint...")
	# TODO: Implement respawn logic

# Memory Management
func collect_memory(memory_name: String, memory_type: String, power: int = 10) -> bool:
	var new_memory = {
		"name": memory_name,
		"type": memory_type,
		"power": power,
		"collected_at_circle": current_circle,
		"timestamp": Time.get_ticks_msec()
	}
	memories.append(new_memory)
	memory_collected.emit(new_memory)
	return true

func use_memory(memory_index: int) -> bool:
	if memory_index >= memories.size():
		return false
	var memory = memories[memory_index]
	equipped_memory = memory
	return true

func consume_memory(memory_index: int) -> Dictionary:
	if memory_index >= memories.size():
		return {}
	var consumed = memories[memory_index]
	memories.remove_at(memory_index)
	return consumed

func get_memory_count() -> int:
	return memories.size()

func get_memories_of_type(type: String) -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []
	for memory in memories:
		if memory["type"] == type:
			filtered.append(memory)
	return filtered

# Circle Management
func visit_circle(circle: int):
	if circle > 0 and circle <= 9:
		circle_progress[circle]["visited"] = true

func progress_circle(circle: int, enemies_defeated: int = 1):
	if circle > 0 and circle <= 9:
		circle_progress[circle]["enemies_defeated"] += enemies_defeated

func complete_circle(circle: int):
	if circle > 0 and circle <= 9:
		circle_progress[circle]["completed"] = true
		if circle < 9:
			current_circle = circle + 1
			circle_progressed.emit(current_circle)

func get_circle_progress(circle: int) -> Dictionary:
	if circle in circle_progress:
		return circle_progress[circle]
	return {}

# Save/Load
func save_progress(path: String = "user://saves/progress.json"):
	var save_data = {
		"state": current_state,
		"health": current_health,
		"circle": current_circle,
		"memories": memories,
		"circle_progress": circle_progress,
		"timestamp": Time.get_ticks_msec()
	}
	var json = JSON.stringify(save_data)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json)

func load_progress(path: String = "user://saves/progress.json") -> bool:
	if not ResourceLoader.exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var json = JSON.new()
		if json.parse(json_string) == OK:
			var data = json.data
			current_state = data.get("state", "adult")
			current_health = data.get("health", max_health)
			current_circle = data.get("circle", 1)
			memories = data.get("memories", [])
			circle_progress = data.get("circle_progress", {})
			return true
	return false
