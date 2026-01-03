extends Node

# CombatSystem Singleton - Turn-based combat with Contrapasso
signal combat_started(enemy: Node)
signal player_turn_started
signal enemy_turn_started
signal combat_ended(victor: String)
signal contrapasso_triggered(sin_type: String, effect: String)

class Enemy:
	var name: String
	var sin_type: String
	var health: int
	var max_health: int
	var attack_power: int
	var defense: int
	var reward_memory: String
	
	func _init(p_name: String, p_sin: String, p_health: int, p_attack: int, p_def: int, p_memory: String):
		name = p_name
		sin_type = p_sin
		health = p_health
		max_health = p_health
		attack_power = p_attack
		defense = p_def
		reward_memory = p_memory
	
func take_damage(amount: int) -> int:
		var damage = max(1, amount - (defense / 2))
		health -= damage
		return damage
	
func heal(amount: int):
		health = min(max_health, health + amount)

func is_alive() -> bool:
		return health > 0

func get_health_percentage() -> float:
		return float(health) / float(max_health)

# Combat State
var current_enemy: Enemy = null
var in_combat: bool = false
var current_turn: String = "player"  # "player" or "enemy"
var turn_timer: float = 0.0
var player_action_queue: Array[String] = []

func _ready():
	add_to_group("autoload")
	_initialize_enemy_registry()

func _process(delta: float):
	if not in_combat:
		return
	
	turn_timer -= delta
	if turn_timer <= 0 and current_turn == "enemy":
		execute_enemy_turn()

func _initialize_enemy_registry():
	# Limbo enemies
	register_enemy(Enemy.new(
		"Neutral Shade",
		"limbo",
		30, 5, 2,
		"regret"
	))
	
	# Lust circle enemies
	register_enemy(Enemy.new(
		"Siren of Desire",
		"lust",
		35, 8, 2,
		"desire"
	))
	register_enemy(Enemy.new(
		"Passion Beast",
		"lust",
		40, 10, 3,
		"desire"
	))
	
	# Gluttony circle enemies
	register_enemy(Enemy.new(
		"Bloated Glutton",
		"gluttony",
		45, 9, 3,
		"joy"
	))
	
	# Greed circle enemies
	register_enemy(Enemy.new(
		"Hoarder Shadow",
		"greed",
		38, 11, 4,
		"trauma"
	))
	
	# Wrath circle enemies
	register_enemy(Enemy.new(
		"Rage Incarnate",
		"wrath",
		50, 15, 2,
		"anger"
	))

var enemy_registry: Dictionary = {}

func register_enemy(enemy: Enemy):
	enemy_registry[enemy.name] = enemy

func spawn_enemy(enemy_name: String) -> Enemy:
	var template = enemy_registry.get(enemy_name, null)
	if not template:
		push_error("Enemy not found: " + enemy_name)
		return null
	
	var enemy = Enemy.new(template.name, template.sin_type, template.max_health, 
		                     template.attack_power, template.defense, template.reward_memory)
	return enemy

# Combat Flow
func start_combat(enemy: Enemy) -> bool:
	if in_combat:
		return false
	
	in_combat = true
	current_enemy = enemy
	current_turn = "player"
	turn_timer = 5.0  # 5 seconds to decide action
	combat_started.emit(enemy)
	player_turn_started.emit()
	return true

func execute_player_action(action: String) -> bool:
	if current_turn != "player" or not in_combat:
		return false
	
	match action:
		"attack":
			var damage = _calculate_damage(PlayerData.max_health / 10)
			var actual_damage = current_enemy.take_damage(damage)
			
		"defend":
			# Next enemy attack deals 30% less damage
			pass
		
		"skill":
			if PlayerData.equipped_memory:
				MemorySystem.use_skill(PlayerData.equipped_memory["name"])
		
		"contrapasso":
			if _trigger_contrapasso():
				turn_timer = 0
				await get_tree().create_timer(1.5).timeout
				current_turn = "player"  # Contrapasso grants another turn
				return true
	
	# Check if enemy is defeated
	if not current_enemy.is_alive():
		end_combat("player")
		return true
	
	# Switch to enemy turn
	current_turn = "enemy"
	turn_timer = 2.0
	enemy_turn_started.emit()
	return true

func execute_enemy_turn() -> bool:
	if current_turn != "enemy" or not in_combat or not current_enemy:
		return false
	
	# Simple AI: Attack or defend based on health
	if current_enemy.get_health_percentage() < 0.3:
		current_enemy.heal(int(current_enemy.max_health * 0.2))
	else:
		var damage = current_enemy.attack_power + randi_range(-2, 2)
		PlayerData.take_damage(damage)
	
	# Check if player is defeated
	if PlayerData.current_health <= 0:
		end_combat("enemy")
		return true
	
	# Return to player turn
	current_turn = "player"
	turn_timer = 5.0
	player_turn_started.emit()
	return true

func _trigger_contrapasso() -> bool:
	if not current_enemy:
		return false
	
	# Apply Contrapasso based on sin type
	match current_enemy.sin_type:
		"lust":
			current_enemy.take_damage(int(current_enemy.max_health * 0.15))
			contrapasso_triggered.emit("lust", "passion_confusion")
		
		"gluttony":
			current_enemy.health = max(0, current_enemy.health - 20)
			contrapasso_triggered.emit("gluttony", "consumption_reversal")
		
		"greed":
			current_enemy.take_damage(int(current_enemy.max_health * 0.25))
			contrapasso_triggered.emit("greed", "resource_theft")
		
		"wrath":
			current_enemy.take_damage(int(current_enemy.attack_power))
			contrapasso_triggered.emit("wrath", "self_harm")
		
		"heresy":
			# Flip enemy logic temporarily
			contrapasso_triggered.emit("heresy", "belief_inversion")
		
		"violence":
			current_enemy.take_damage(int(current_enemy.max_health * 0.3))
			contrapasso_triggered.emit("violence", "wound_reflection")
		
		"fraud":
			# Confuse enemy, reduce accuracy next turn
			contrapasso_triggered.emit("fraud", "deception_reversal")
		
		"treachery":
			current_enemy.take_damage(int(current_enemy.max_health * 0.4))
			contrapasso_triggered.emit("treachery", "betrayal_echo")
		
		_:
			current_enemy.take_damage(10)
	
	return true

func end_combat(victor: String) -> bool:
	if not in_combat:
		return false
	
	in_combat = false
	
	if victor == "player" and current_enemy:
		# Grant rewards
		PlayerData.collect_memory(current_enemy.name, current_enemy.reward_memory, 15)
		PlayerData.progress_circle(PlayerData.current_circle, 1)
	
	combat_ended.emit(victor)
	return true

func _calculate_damage(base_damage: int) -> int:
	return base_damage + randi_range(-3, 5)

func flee_combat() -> bool:
	if not in_combat:
		return false
	
	# 50% chance to flee
	if randf() > 0.5:
		end_combat("fled")
		return true
	else:
		# Failed flee: enemy gets free attack
		execute_enemy_turn()
		return false

func get_combat_status() -> Dictionary:
	return {
		"in_combat": in_combat,
		"current_turn": current_turn,
		"player_health": PlayerData.current_health,
		"enemy_name": current_enemy.name if current_enemy else "",
		"enemy_health": current_enemy.health if current_enemy else 0,
		"enemy_health_percent": current_enemy.get_health_percentage() if current_enemy else 0.0
	}

# Helper functions used by MemorySystem
func deal_damage_to_enemy(amount: int):
	if current_enemy and in_combat:
		current_enemy.take_damage(amount)

func steal_enemy_resource(amount: int):
	if current_enemy and in_combat:
		current_enemy.health -= amount

func slow_enemy(duration: float):
	if current_enemy and in_combat:
		# TODO: Implement slow effect
		pass

func freeze_enemy(duration: float):
	if current_enemy and in_combat:
		# TODO: Implement freeze effect
		pass

func enemy_damage_self(amount: int):
	if current_enemy and in_combat:
		current_enemy.take_damage(amount)
