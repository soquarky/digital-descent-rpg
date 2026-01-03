extends Node

# DialogueSystem Singleton - Manages ARIA and NPC dialogue
signal dialogue_started(speaker: String)
signal dialogue_line_displayed(line: String, speaker: String)
signal dialogue_ended
signal choice_presented(choices: Array[String])
signal choice_selected(choice: String)

class DialogueLine:
	var speaker: String
	var text: String
	var emotion: String = "neutral"
	var choices: Array[String] = []
	
	func _init(p_speaker: String, p_text: String, p_emotion: String = "neutral"):
		speaker = p_speaker
		text = p_text
		emotion = p_emotion

var dialogue_tree: Dictionary = {}
var current_dialogue_id: String = ""
var current_line_index: int = 0
var is_dialogue_active: bool = false
var dialogue_history: Array[Dictionary] = []

func _ready():
	add_to_group("autoload")
	_initialize_dialogue_trees()

func _initialize_dialogue_trees():
	# ARIA - Welcome dialogue (Limbo intro)
	dialogue_tree["aria_welcome"] = [
		DialogueLine.new("ARIA", "Welcome, lost soul. I am ARIA—your guide through the digital abyss.", "calm"),
		DialogueLine.new("ARIA", "You have awakened in a place between worlds, neither alive nor dead.", "mysterious"),
		DialogueLine.new("ARIA", "Do you remember who you are?", "questioning"),
	]
	
	# Tutorial dialogue
	dialogue_tree["tutorial_state_switch"] = [
		DialogueLine.new("ARIA", "You possess a unique ability: you can perceive reality through two lenses.", "informative"),
		DialogueLine.new("ARIA", "As an adult, you see logic and structure. As a child, you see emotion and truth.", "informative"),
		DialogueLine.new("ARIA", "Together, you may navigate the puzzles that bind you here.", "hopeful"),
	]
	
	# Memory collection dialogue
	dialogue_tree["memory_collected"] = [
		DialogueLine.new("ARIA", "A memory has surfaced. Your past is trying to speak to you.", "mysterious"),
	]
	
	# Limbo shade encounter
	dialogue_tree["neutral_shade_encounter"] = [
		DialogueLine.new("Neutral Shade", "Another wanderer in the gray...", "hollow"),
		DialogueLine.new("ARIA", "This being was neither blessed nor damned. Approach with caution.", "warning"),
	]
	
	# Enemy defeat
	dialogue_tree["enemy_defeated_lust"] = [
		DialogueLine.new("ARIA", "You have conquered the Siren's pull. The path forward opens.", "triumphant"),
	]
	
	# Circle complete
	dialogue_tree["limbo_complete"] = [
		DialogueLine.new("ARIA", "You have traversed the first circle—Limbo, the place of the virtuous unbaptized.", "solemn"),
		DialogueLine.new("ARIA", "But deeper torments await. Each circle will demand more of you.", "grim"),
	]
	
	# Lust circle introduction
	dialogue_tree["circle_2_intro"] = [
		DialogueLine.new("ARIA", "You descend into the second circle—Lust.", "tense"),
		DialogueLine.new("ARIA", "Here, passion binds souls in an eternal wind, forever swept away from peace.", "poetic"),
		DialogueLine.new("ARIA", "What desires drove you before? They wait here still.", "haunting"),
	]

func start_dialogue(dialogue_id: String) -> bool:
	if dialogue_id not in dialogue_tree:
		push_error("Dialogue not found: " + dialogue_id)
		return false
	
	if is_dialogue_active:
		return false
	
	current_dialogue_id = dialogue_id
	current_line_index = 0
	is_dialogue_active = true
	dialogue_started.emit(dialogue_id)
	display_current_line()
	return true

func display_current_line() -> bool:
	if not is_dialogue_active or current_dialogue_id not in dialogue_tree:
		return false
	
	var dialogue = dialogue_tree[current_dialogue_id]
	if current_line_index >= dialogue.size():
		end_dialogue()
		return false
	
	var line = dialogue[current_line_index]
	dialogue_history.append({
		"speaker": line.speaker,
		"text": line.text,
		"emotion": line.emotion,
		"timestamp": Time.get_ticks_msec()
	})
	
	dialogue_line_displayed.emit(line.text, line.speaker)
	
	if line.choices.size() > 0:
		choice_presented.emit(line.choices)
	
	return true

func next_line() -> bool:
	if not is_dialogue_active:
		return false
	
	current_line_index += 1
	return display_current_line()

func select_choice(choice_index: int) -> bool:
	if not is_dialogue_active or current_dialogue_id not in dialogue_tree:
		return false
	
	var dialogue = dialogue_tree[current_dialogue_id]
	if current_line_index >= dialogue.size():
		return false
	
	var line = dialogue[current_line_index]
	if choice_index >= line.choices.size():
		return false
	
	choice_selected.emit(line.choices[choice_index])
	return next_line()

func end_dialogue() -> bool:
	if not is_dialogue_active:
		return false
	
	is_dialogue_active = false
	current_dialogue_id = ""
	current_line_index = 0
	dialogue_ended.emit()
	return true

func add_dialogue_tree(dialogue_id: String, lines: Array[DialogueLine]):
	dialogue_tree[dialogue_id] = lines

func get_dialogue_history() -> Array[Dictionary]:
	return dialogue_history

func clear_dialogue_history():
	dialogue_history.clear()

func is_aria_dialogue(dialogue_id: String) -> bool:
	return dialogue_id.begins_with("aria_")

# ARIA Dynamic responses based on player state
func get_aria_commentary(event: String) -> String:
	match event:
		"player_low_health":
			return "Your form is fading. We must find rest."
		"player_switch_child":
			return "Ah, you see through a child's eyes now. What truths emerge?"
		"player_switch_adult":
			return "Adult perspective returned. Logic and reason reassert themselves."
		"memory_collected":
			return "Another fragment of your past surfaces."
		"puzzle_solved":
			return "Clever. You understand the mechanism of your imprisonment."
		"enemy_defeated":
			return "One tormentor vanquished. But the circle is not yet complete."
		_:
			return "..."

func aria_hints(circle: int) -> Array[String]:
	match circle:
		1:
			return [
				"These virtuous shades never knew salvation. Perhaps they can teach you something.",
				"Look for symbols that appear in both adult and child vision.",
			]
		2:
			return [
				"Passion clouds judgment. Resist the Sirens' call.",
				"Your desires may unlock a path the practical mind cannot see.",
			]
		3:
			return [
				"Consumption without restraint leads only to emptiness.",
				"The adult controls resources; the child sees their true worth.",
			]
		_:
			return ["The path ahead is shrouded in mystery."]
