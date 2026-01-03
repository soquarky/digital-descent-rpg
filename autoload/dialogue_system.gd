extends Node
## Dialogue System - Manages conversations and narrative moments

signal dialogue_line_displayed(speaker: String, text: String)
signal dialogue_choice_required(choices: Array)
signal dialogue_sequence_complete()

var active_dialogue: Dictionary = {}
var current_line_index: int = 0
var is_active: bool = false

func start_dialogue(dialogue_id: String, dialogue_data: Dictionary):
	"""Begin a dialogue sequence"""
	active_dialogue = dialogue_data
	current_line_index = 0
	is_active = true
	
	GameManager.change_game_state(GameManager.GameState.DIALOGUE)
	
	_display_next_line()

func _display_next_line():
	if current_line_index >= active_dialogue.get("lines", []).size():
		end_dialogue()
		return
	
	var line = active_dialogue["lines"][current_line_index]
	
	# Check for conditional lines based on mental state
	if "condition" in line:
		if not _check_condition(line["condition"]):
			current_line_index += 1
			_display_next_line()
			return
	
	var speaker = line.get("speaker", "???")
	var text = line.get("text", "")
	
	dialogue_line_displayed.emit(speaker, text)
	
	# Check if this line has choices
	if "choices" in line:
		dialogue_choice_required.emit(line["choices"])

func advance_dialogue():
	"""Move to next line"""
	current_line_index += 1
	_display_next_line()

func make_choice(choice_index: int):
	"""Player selects a dialogue choice"""
	var line = active_dialogue["lines"][current_line_index]
	
	if "choices" in line:
		var choice = line["choices"][choice_index]
		
		# Apply choice consequences
		if "effect" in choice:
			_apply_dialogue_effect(choice["effect"])
		
		# Jump to specific line if specified
		if "goto" in choice:
			current_line_index = choice["goto"]
		else:
			current_line_index += 1
		
		_display_next_line()

func _check_condition(condition: Dictionary) -> bool:
	"""Check if a condition is met"""
	match condition.get("type", ""):
		"mental_state":
			return PlayerData.current_state == condition.get("value", 0)
		"has_fragment":
			return condition.get("value", "") in PlayerData.memory_fragments
		"circle":
			return PlayerData.current_circle >= condition.get("value", 0)
		_:
			return true

func _apply_dialogue_effect(effect: Dictionary):
	"""Apply effects from dialogue choices"""
	match effect.get("type", ""):
		"add_memory":
			PlayerData.add_memory_fragment(effect.get("fragment_id", ""), {})
		"damage_memory":
			PlayerData.damage_hyperthymesia(effect.get("amount", 0))
		"aria_speaks":
			var aria = get_tree().get_first_node_in_group("aria_companion")
			if aria:
				aria.speak(effect.get("text", ""))

func end_dialogue():
	"""Complete dialogue sequence"""
	is_active = false
	active_dialogue = {}
	current_line_index = 0
	
	dialogue_sequence_complete.emit()
	GameManager.change_game_state(GameManager.GameState.PLAYING)

# Sample dialogue database
func get_sample_dialogue() -> Dictionary:
	return {
		"gate_of_hell": {
			"lines": [
				{
					"speaker": "ARIA",
					"text": "We've reached the gate. The inscription... it's corrupted."
				},
				{
					"speaker": "Gate Inscription",
					"text": "ABANDON ALL HOPE, YE WHO ENTER HERE—\\nUNLESS YOU HAVE PROPER INSURANCE."
				},
				{
					"speaker": "Agent Morrison",
					"text": "The path ahead descends through nine circles. You ready?",
					"choices": [
						{
							"text": "[ADULT] Let's proceed systematically.",
							"effect": {"type": "set_mental_state", "value": 0}
						},
						{
							"text": "[CHILD] I'm scared, but I trust you.",
							"effect": {"type": "set_mental_state", "value": 1}
						}
					]
				}
			]
		}
	}