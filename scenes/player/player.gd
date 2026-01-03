extends CharacterBody2D
class_name Player

# Dual mind state system
enum MindState { ADULT, CHILD }

@export var adult_speed: float = 200.0
@export var child_speed: float = 150.0
@export var adult_health: int = 100
@export var child_health: int = 80

var current_state: MindState = MindState.ADULT
var current_health: int
var current_speed: float

# Combat
var in_combat: bool = false
var combat_target: Node = null

# Animation and sprites
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal state_changed(new_state: MindState)
signal health_changed(new_health: int)
signal entered_combat
signal exited_combat

func _ready() -> void:
	_initialize_state()
	PlayerData.connect("state_switched", _on_state_switched)

func _initialize_state() -> void:
	current_state = PlayerData.current_state
	_update_stats()

func _update_stats() -> void:
	match current_state:
		MindState.ADULT:
			current_speed = adult_speed
			current_health = adult_health
			# Visual: Adult form (darker, more defined)
		MindState.CHILD:
			current_speed = child_speed
			current_health = child_health
			# Visual: Child form (softer, vulnerable)
	
	health_changed.emit(current_health)

func _physics_process(delta: float) -> void:
	if in_combat:
		return
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = input_vector * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, current_speed)
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	# State switch (only outside combat)
	if event.is_action_pressed("switch_state") and not in_combat:
		toggle_state()
	
	# Interact
	if event.is_action_pressed("interact"):
		_try_interact()
	
	# Memory recall (special ability)
	if event.is_action_pressed("recall_memory"):
		_activate_memory_recall()

func toggle_state() -> void:
	if current_state == MindState.ADULT:
		current_state = MindState.CHILD
	else:
		current_state = MindState.ADULT
	
	PlayerData.switch_state(current_state)
	_update_stats()
	state_changed.emit(current_state)
	
	# Play transformation animation
	if animation_player:
		animation_player.play("transform")

func _on_state_switched(new_state: MindState) -> void:
	current_state = new_state
	_update_stats()

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		_die()

func heal(amount: int) -> void:
	var max_health = adult_health if current_state == MindState.ADULT else child_health
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health)

func _die() -> void:
	GameManager.player_died()
	# Respawn logic or game over

func enter_combat(target: Node) -> void:
	in_combat = true
	combat_target = target
	entered_combat.emit()

func exit_combat() -> void:
	in_combat = false
	combat_target = null
	exited_combat.emit()

func _try_interact() -> void:
	# Raycast or area detection for interactables
	var interactables = get_tree().get_nodes_in_group("interactable")
	for obj in interactables:
		if obj.has_method("is_in_range") and obj.is_in_range(global_position):
			obj.interact(self)
			break

func _activate_memory_recall() -> void:
	# Special ability: recall memory for hint/power
	if MemorySystem.can_recall_memory():
		var memory = MemorySystem.recall_random_memory()
		if memory:
			# Apply memory effect (heal, buff, reveal, etc.)
			pass
