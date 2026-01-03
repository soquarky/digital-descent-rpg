extends Node

enum MentalState { ADULT, CHILD }

# Core player stats
var health: float = 100.0
var max_health: float = 100.0
var hyperthymesia_integrity: float = 100.0  # Perfect recall at 100%

# Mental state tracking
var current_state: MentalState = MentalState.ADULT
var state_switch_cooldown: float = 0.0
const STATE_SWITCH_COOLDOWN_TIME: float = 1.0

# Memory and progression
var memory_fragments: Array[String] = []
var circles_completed: int = 0
var current_circle: int = 1

# Neural pathway strengths (skill progression)
var neural_pathways: Dictionary = {
	"logic": 0,        # Adult mind power
	"intuition": 0,   # Child mind power
	"investigation": 0,  # FBI skills
	"empathy": 0      # Healing/bonding
}

# Signals
signal state_changed(new_state: MentalState)
signal health_changed(new_health: float)
signal hyperthymesia_damaged(new_integrity: float)
signal memory_fragment_collected(fragment_id: String)

func _ready():
	print("[PlayerData] Initialized")

func switch_state():
	"""Toggle between ADULT and CHILD states"""
	if state_switch_cooldown > 0:
		return
	
	if current_state == MentalState.ADULT:
		current_state = MentalState.CHILD
	else:
		current_state = MentalState.ADULT
	
	state_switch_cooldown = STATE_SWITCH_COOLDOWN_TIME
	state_changed.emit(current_state)
	
	print("[PlayerData] Switched to state: ", "CHILD" if current_state == MentalState.CHILD else "ADULT")

func _process(delta):
	if state_switch_cooldown > 0:
		state_switch_cooldown -= delta

func take_damage(amount: float):
	"""Reduce health"""
	health = max(0, health - amount)
	health_changed.emit(health)
	
	if health <= 0:
		die()

func heal(amount: float):
	"""Restore health"""
	health = min(max_health, health + amount)
	health_changed.emit(health)

func damage_hyperthymesia(amount: float):
	"""Damage perfect memory - affects abilities"""
	hyperthymesia_integrity = max(0, hyperthymesia_integrity - amount)
	hyperthymesia_damaged.emit(hyperthymesia_integrity)
	
	if hyperthymesia_integrity < 30:
		print("[WARNING] Hyperthymesia critically damaged!")
		# ARIA companion may glitch

func add_memory_fragment(fragment_id: String, fragment_data: Dictionary):
	"""Collect a memory fragment"""
	if fragment_id not in memory_fragments:
		memory_fragments.append(fragment_id)
		# Restore some hyperthymesia
		hyperthymesia_integrity = min(100, hyperthymesia_integrity + 2.0)
		memory_fragment_collected.emit(fragment_id)
		print("[PlayerData] Memory fragment collected: ", fragment_id)

func strengthen_neural_pathway(pathway: String, amount: int):
	"""Increase skill in a pathway"""
	if pathway in neural_pathways:
		neural_pathways[pathway] += amount
		print("[PlayerData] Neural pathway strengthened: ", pathway, " -> ", neural_pathways[pathway])

func complete_circle(circle_number: int):
	"""Mark a circle as completed"""
	circles_completed += 1
	current_circle = circle_number + 1
	print("[PlayerData] Circle ", circle_number, " completed!")

func die():
	"""Handle player death"""
	print("[PlayerData] Player died")
	GameManager.game_over()

func get_state_name() -> String:
	return "ADULT" if current_state == MentalState.ADULT else "CHILD"

func get_state_color() -> Color:
	# Adult = Cyan, Child = Magenta
	return Color.CYAN if current_state == MentalState.ADULT else Color.MAGENTA