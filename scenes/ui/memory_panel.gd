extends Control
class_name MemoryPanel

# Display collected memory fragments

@onready var memory_grid: GridContainer = $Panel/ScrollContainer/MemoryGrid
@onready var detail_panel: PanelContainer = $DetailPanel
@onready var detail_label: RichTextLabel = $DetailPanel/DetailLabel

var memory_buttons: Array[Button] = []

signal memory_selected(memory_data: Dictionary)

func _ready() -> void:
	MemorySystem.connect("memory_collected", _on_memory_collected)
	detail_panel.hide()
	_refresh_memories()

func _refresh_memories() -> void:
	# Clear existing
	for button in memory_buttons:
		button.queue_free()
	memory_buttons.clear()
	
	# Display all collected memories
	var memories = MemorySystem.get_all_memories()
	for memory in memories:
		var button = _create_memory_button(memory)
		memory_grid.add_child(button)
		memory_buttons.append(button)

func _create_memory_button(memory: Dictionary) -> Button:
	var button = Button.new()
	button.text = memory.get("type", "Unknown").capitalize()
	button.custom_minimum_size = Vector2(80, 80)
	
	# Visual style based on memory type
	var style = StyleBoxFlat.new()
	match memory.get("type", ""):
		"trauma":
			style.bg_color = Color(0.8, 0.2, 0.2)
		"joy":
			style.bg_color = Color(0.2, 0.8, 0.8)
		"regret":
			style.bg_color = Color(0.4, 0.4, 0.6)
		_:
			style.bg_color = Color(0.5, 0.5, 0.5)
	
	button.add_theme_stylebox_override("normal", style)
	button.connect("pressed", func(): _on_memory_button_pressed(memory))
	
	return button

func _on_memory_button_pressed(memory: Dictionary) -> void:
	_show_memory_detail(memory)
	memory_selected.emit(memory)

func _show_memory_detail(memory: Dictionary) -> void:
	var detail_text = ""
	detail_text += "[b]" + memory.get("type", "Unknown").capitalize() + "[/b]\n\n"
	detail_text += memory.get("description", "No description")
	detail_text += "\n\nCircle: " + str(memory.get("circle", 0))
	
	detail_label.text = detail_text
	detail_panel.show()

func _on_memory_collected(memory: Dictionary) -> void:
	_refresh_memories()
	
	# Show notification
	var notification = Label.new()
	notification.text = "Memory Collected: " + memory.get("type", "Unknown")
	notification.position = Vector2(400, 100)
	add_child(notification)
	
	await get_tree().create_timer(2.0).timeout
	notification.queue_free()
