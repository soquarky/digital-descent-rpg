extends Node2D
class_name Circle1Limbo

# First circle: Limbo - Virtuous pagans and unbaptized
# Theme: Endless gray fields, neither punishment nor reward

@onready var player: Player = $Player
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var exit_portal: Area2D = $ExitPortal
@onready var aria_npc: Node2D = $ARIA

var circle_number: int = 1
var entered: bool = false

signal circle_completed

func _ready() -> void:
	GameManager.set_current_circle(circle_number)
	
	if player:
		player.global_position = spawn_point.global_position
	
	if exit_portal:
		exit_portal.connect("body_entered", _on_exit_portal_entered)
	
	# First time entry dialogue
	if not entered:
		_play_intro_dialogue()
		entered = true

func _play_intro_dialogue() -> void:
	var dialogue_data = {
		"speaker": "ARIA",
		"lines": [
			{
				"speaker": "ARIA",
				"text": "Welcome to Limbo, the first circle. This is where those who lived virtuously, but without faith, reside."
			},
			{
				"speaker": "ARIA",
				"text": "Here, you'll learn to navigate between your adult and child perspectives. Each offers different strengths."
			},
			{
				"speaker": "ARIA",
				"text": "Collect memory fragments to unlock your past and grow stronger. But be warned—the deeper circles hold darker truths."
			}
		]
	}
	
	DialogueSystem.start_dialogue(dialogue_data)

func _on_exit_portal_entered(body: Node2D) -> void:
	if body is Player:
		# Check if player has completed circle objectives
		if _check_circle_completion():
			_complete_circle()
		else:
			_show_incomplete_message()

func _check_circle_completion() -> bool:
	# Example: Collect 3 memories and defeat 1 enemy
	var memories = MemorySystem.get_memories_from_circle(circle_number)
	return memories.size() >= 3

func _complete_circle() -> void:
	circle_completed.emit()
	GameManager.circle_completed(circle_number)
	
	# Transition to next circle
	get_tree().change_scene_to_file("res://scenes/levels/circle_2_lust.tscn")

func _show_incomplete_message() -> void:
	var ui = get_node("/root/DialogueUI")
	if ui:
		ui.show_aria_hint("You're not ready to descend yet. Explore and gather more memories.")
