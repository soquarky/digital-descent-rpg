extends CharacterBody2D
class_name Enemy

# Enemy types based on Dante's sins
enum SinType { LUST, GLUTTONY, GREED, WRATH, HERESY, VIOLENCE, FRAUD, TREACHERY }

@export var enemy_name: String = "Lost Soul"
@export var sin_type: SinType = SinType.LUST
@export var max_health: int = 50
@export var attack_power: int = 10
@export var speed: float = 100.0

var current_health: int
var in_combat: bool = false
var target: Node = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var detection_area: Area2D = $DetectionArea

signal died
signal entered_combat
signal health_changed(new_health: int)

func _ready() -> void:
	current_health = max_health
	detection_area.connect("body_entered", _on_detection_area_entered)

func _physics_process(delta: float) -> void:
	if in_combat or not target:
		return
	
	# Move toward player
	var direction = (target.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_detection_area_entered(body: Node2D) -> void:
	if body is Player:
		target = body
		_initiate_combat()

func _initiate_combat() -> void:
	if in_combat:
		return
	
	in_combat = true
	entered_combat.emit()
	
	# Start combat with player
	if target is Player:
		var combat = get_node("/root/CombatSystem")
		if combat:
			combat.start_combat(target, [self])

func enter_combat() -> void:
	in_combat = true

func exit_combat() -> void:
	in_combat = false
	target = null

func decide_action(player: Player) -> Dictionary:
	# AI decision based on sin type and state
	var action = {
		"actor": self,
		"type": "attack",
		"target": player
	}
	
	match sin_type:
		SinType.LUST:
			# Lustful enemies distract/confuse
			if randf() < 0.3:
				action["type"] = "confuse"
		SinType.GLUTTONY:
			# Gluttonous consume/drain
			if current_health < max_health * 0.5:
				action["type"] = "drain"
		SinType.GREED:
			# Greedy steal/debuff
			if randf() < 0.4:
				action["type"] = "steal"
		SinType.WRATH:
			# Wrathful always attack aggressively
			action["type"] = "berserk_attack"
		SinType.VIOLENCE:
			# Violent multi-hit
			if randf() < 0.5:
				action["type"] = "multi_attack"
		SinType.FRAUD:
			# Fraudulent deceive
			action["type"] = "deception"
		SinType.TREACHERY:
			# Treacherous backstab
			action["type"] = "backstab"
	
	return action

func take_damage(amount: int) -> void:
	current_health -= amount
	health_changed.emit(current_health)
	
	if current_health <= 0:
		_die()

func _die() -> void:
	died.emit()
	
	# Drop memory fragment
	_drop_memory()
	
	# Play death animation
	queue_free()

func _drop_memory() -> void:
	var memory_data = {
		"type": _sin_to_memory_type(),
		"description": "A fragment of " + enemy_name + "'s torment",
		"circle": GameManager.current_circle
	}
	MemorySystem.add_memory(memory_data)

func _sin_to_memory_type() -> String:
	match sin_type:
		SinType.LUST: return "desire"
		SinType.GLUTTONY: return "excess"
		SinType.GREED: return "avarice"
		SinType.WRATH: return "anger"
		SinType.VIOLENCE: return "trauma"
		SinType.FRAUD: return "deception"
		SinType.TREACHERY: return "betrayal"
		_: return "unknown"

func get_sin_type() -> SinType:
	return sin_type

func is_alive() -> bool:
	return current_health > 0

func apply_debuff(debuff_name: String, duration: int) -> void:
	# Apply status effect
	pass

func apply_vulnerability(multiplier: float) -> void:
	# Make enemy take more damage
	pass

func drain_resources() -> void:
	# Greedy enemies lose resources
	pass
