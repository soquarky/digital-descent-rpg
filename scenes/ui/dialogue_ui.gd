extends Control
class_name DialogueUI

# UI for dialogue and ARIA companion

@onready var dialogue_box: PanelContainer = $DialogueBox
@onready var speaker_label: Label = $DialogueBox/VBox/SpeakerLabel
@onready var text_label: RichTextLabel = $DialogueBox/VBox/TextLabel
@onready var choices_container: VBoxContainer = $DialogueBox/VBox/ChoicesContainer
@onready var continue_button: Button = $DialogueBox/VBox/ContinueButton

var current_dialogue: Dictionary
var choice_buttons: Array[Button] = []

signal dialogue_finished
signal choice_selected(choice_index: int)

func _ready() -> void:
	hide()
	DialogueSystem.connect("dialogue_started", _on_dialogue_started)
	DialogueSystem.connect("dialogue_line_changed", _on_dialogue_line_changed)
	DialogueSystem.connect("dialogue_ended", _on_dialogue_ended)
	
	continue_button.connect("pressed", _on_continue_pressed)

func _on_dialogue_started(dialogue_data: Dictionary) -> void:
	current_dialogue = dialogue_data
	show()
	_display_line(0)

func _on_dialogue_line_changed(line_data: Dictionary) -> void:
	speaker_label.text = line_data.get("speaker", "???")
	text_label.text = line_data.get("text", "")
	
	# Handle choices
	_clear_choices()
	if line_data.has("choices"):
		_display_choices(line_data["choices"])
		continue_button.hide()
	else:
		continue_button.show()

func _on_dialogue_ended() -> void:
	hide()
	dialogue_finished.emit()

func _display_line(line_index: int) -> void:
	if not current_dialogue.has("lines"):
		return
	
	var lines = current_dialogue["lines"]
	if line_index >= lines.size():
		DialogueSystem.end_dialogue()
		return
	
	var line = lines[line_index]
	_on_dialogue_line_changed(line)

func _display_choices(choices: Array) -> void:
	for i in range(choices.size()):
		var button = Button.new()
		button.text = choices[i]
		button.connect("pressed", func(): _on_choice_pressed(i))
		choices_container.add_child(button)
		choice_buttons.append(button)

func _clear_choices() -> void:
	for button in choice_buttons:
		button.queue_free()
	choice_buttons.clear()

func _on_choice_pressed(choice_index: int) -> void:
	choice_selected.emit(choice_index)
	DialogueSystem.make_choice(choice_index)

func _on_continue_pressed() -> void:
	DialogueSystem.advance_dialogue()

func show_aria_hint(hint_text: String) -> void:
	# ARIA companion hint system
	speaker_label.text = "ARIA"
	text_label.text = hint_text
	show()
	
	# Auto-hide after delay
	await get_tree().create_timer(3.0).timeout
	hide()
