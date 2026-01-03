extends CharacterBody2D

# Player Controller - Core movement and state management
const ADULT_SPEED = 150.0
const CHILD_SPEED = 200.0
const GRAVITY = 900.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var state_transition = $StateTransition

var is_moving = false
var can_switch_state = true
var state_animation_playing = false

func _ready():
	# Connect to PlayerData signals
	PlayerData.state_changed.connect(_on_state_changed)
	PlayerData.health_changed.connect(_on_health_changed)
	
	# Connect to CombatSystem signals
	CombatSystem.combat_started.connect(_on_combat_started)
	CombatSystem.combat_ended.connect(_on_combat_ended)
	
	# Set initial state
	_update_appearance()

func _physics_process(delta: float):
	# Don't move during cutscenes or combat
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	
	# Get input
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Handle state switching (Space)
	if Input.is_action_just_pressed("ui_select") and can_switch_state and not CombatSystem.in_combat:
		_toggle_state()
	
	# Movement
	if input_vector != Vector2.ZERO:
		var speed = CHILD_SPEED if PlayerData.is_child_state() else ADULT_SPEED
		velocity = input_vector.normalized() * speed
		is_moving = true
		
		# Update animation
		if animation_player:
			if not animation_player.is_playing():
				animation_player.play("walk")
	else:
		velocity = Vector2.ZERO
		is_moving = false
		if animation_player:
			animation_player.play("idle")
	
	# Apply velocity
	move_and_slide()

func _toggle_state():
	if not can_switch_state or CombatSystem.in_combat:
		return
	
	can_switch_state = false
	state_animation_playing = true
	
	# Play transition animation
	if animation_player and animation_player.has_animation("state_switch"):
		animation_player.play("state_switch")
		await animation_player.animation_finished
	else:
		# Fallback: instant 0.3s transition
		await get_tree().create_timer(0.3).timeout
	
	# Actually toggle the state
	PlayerData.toggle_state()
	_update_appearance()
	
	state_animation_playing = false
	can_switch_state = true

func _update_appearance():
	# Update sprite and collision based on current state
	if PlayerData.is_adult_state():
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)  # Normal
		sprite.scale = Vector2(1.0, 1.0)
	else:  # Child state
		sprite.modulate = Color(0.8, 1.0, 1.0, 1.0)  # Slight blue tint
		sprite.scale = Vector2(0.7, 0.7)  # Smaller

func _on_state_changed(new_state: String):
	_update_appearance()

func _on_health_changed(new_health: int):
	print("Player health: ", new_health, "/", PlayerData.max_health)
	# TODO: Update health bar UI

func _on_combat_started(enemy: Node):
	print("Combat started with: ", enemy.name if enemy else "Unknown")
	GameManager.set_game_state(GameManager.GameState.COMBAT)


func _on_combat_ended(victor: String):
	print("Combat ended. Victor: ", victor)
	GameManager.set_game_state(GameManager.GameState.PLAYING)

func take_knockback(direction: Vector2, force: float):
	velocity += direction.normalized() * force
