extends Node
class_name CombatSystem

# Turn-based combat with Dantean contrapasso mechanics

enum TurnPhase { PLAYER, ENEMY, RESOLUTION }

var current_phase: TurnPhase = TurnPhase.PLAYER
var player: Player
var enemies: Array[Node] = []
var current_enemy_index: int = 0

var player_actions: Array[Dictionary] = []
var enemy_actions: Array[Dictionary] = []

signal combat_started
signal combat_ended(victory: bool)
signal phase_changed(phase: TurnPhase)
signal action_executed(actor, action, target)

func _ready() -> void:
	set_process(false)

func start_combat(p: Player, enemy_list: Array) -> void:
	player = p
	enemies = enemy_list
	current_phase = TurnPhase.PLAYER
	set_process(true)
	combat_started.emit()
	
	for enemy in enemies:
		enemy.enter_combat()
	
	phase_changed.emit(current_phase)

func _process(delta: float) -> void:
	match current_phase:
		TurnPhase.PLAYER:
			# Wait for player input
			pass
		TurnPhase.ENEMY:
			_process_enemy_turn()
		TurnPhase.RESOLUTION:
			_resolve_turn()

func player_choose_action(action_type: String, target = null) -> void:
	if current_phase != TurnPhase.PLAYER:
		return
	
	var action = {
		"actor": player,
		"type": action_type,
		"target": target,
		"state": player.current_state
	}
	
	player_actions.append(action)
	_next_phase()

func _process_enemy_turn() -> void:
	enemy_actions.clear()
	
	for enemy in enemies:
		if enemy.is_alive():
			var action = enemy.decide_action(player)
			enemy_actions.append(action)
	
	_next_phase()

func _resolve_turn() -> void:
	# Resolve all actions
	for action in player_actions:
		_execute_action(action)
	
	for action in enemy_actions:
		_execute_action(action)
	
	player_actions.clear()
	enemy_actions.clear()
	
	# Check victory/defeat
	if _check_combat_end():
		return
	
	# Back to player turn
	current_phase = TurnPhase.PLAYER
	phase_changed.emit(current_phase)

func _execute_action(action: Dictionary) -> void:
	var actor = action["actor"]
	var type = action["type"]
	var target = action["target"]
	
	match type:
		"attack":
			var damage = _calculate_damage(actor, target)
			target.take_damage(damage)
		"defend":
			actor.apply_defense_buff()
		"memory_skill":
			_use_memory_skill(actor, target)
		"contrapasso":
			# Special: reflect enemy's sin back at them
			_apply_contrapasso(actor, target)
	
	action_executed.emit(actor, type, target)

func _calculate_damage(attacker, defender) -> int:
	# Base damage modified by state
	var base_damage = 10
	
	if attacker is Player:
		if attacker.current_state == Player.MindState.ADULT:
			base_damage += 5 # Adults hit harder
		else:
			base_damage += 2 # Children are more evasive
	
	return base_damage

func _use_memory_skill(actor, target) -> void:
	# Use collected memories as skills
	var memory = MemorySystem.get_equipped_memory()
	if memory:
		match memory["type"]:
			"trauma":
				# High damage, high cost
				target.take_damage(25)
				actor.take_damage(5)
			"joy":
				# Heal
				actor.heal(15)
			"regret":
				# Debuff enemy
				target.apply_debuff("regret", 3)

func _apply_contrapasso(actor, target) -> void:
	# Contrapasso: punishment fitting the crime
	# Reflect enemy's sin mechanic back at them
	if target.has_method("get_sin_type"):
		var sin = target.get_sin_type()
		match sin:
			"greed":
				# Greedy enemies lose resources
				target.drain_resources()
			"wrath":
				# Wrathful damage themselves
				target.take_damage(15)
			"pride":
				# Proud enemies become vulnerable
				target.apply_vulnerability(2.0)

func _next_phase() -> void:
	match current_phase:
		TurnPhase.PLAYER:
			current_phase = TurnPhase.ENEMY
		TurnPhase.ENEMY:
			current_phase = TurnPhase.RESOLUTION
		TurnPhase.RESOLUTION:
			current_phase = TurnPhase.PLAYER
	
	phase_changed.emit(current_phase)

func _check_combat_end() -> bool:
	# Check if all enemies dead
	var all_dead = true
	for enemy in enemies:
		if enemy.is_alive():
			all_dead = false
			break
	
	if all_dead:
		end_combat(true)
		return true
	
	# Check if player dead
	if player.current_health <= 0:
		end_combat(false)
		return true
	
	return false

func end_combat(victory: bool) -> void:
	set_process(false)
	
	for enemy in enemies:
		enemy.exit_combat()
	
	player.exit_combat()
	combat_ended.emit(victory)
	
	if victory:
		GameManager.combat_won()
	else:
		GameManager.combat_lost()
