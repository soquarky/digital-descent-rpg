extends Node

# MemorySystem Singleton - Advanced memory mechanics
signal memory_skill_used(skill_name: String, effect: String)
signal memory_consumed(memory_type: String)
signal memory_puzzle_solved(puzzle_name: String)

class MemorySkill:
	var name: String
	var memory_type: String
	var power: int
	var cooldown: float = 0.0
	var effect: Callable
	
	func _init(p_name: String, p_type: String, p_power: int, p_effect: Callable):
		name = p_name
		memory_type = p_type
		power = p_power
		effect = p_effect

# Memory Skill Registry
var memory_skills: Dictionary = {}
var active_skills: Array[MemorySkill] = []
var memory_puzzles: Dictionary = {}
var solved_puzzles: Array[String] = []

func _ready():
	add_to_group("autoload")
	_initialize_memory_skills()

func _process(delta: float):
	# Update cooldowns
	for skill in active_skills:
		if skill.cooldown > 0:
			skill.cooldown -= delta

func _initialize_memory_skills():
	# Joy-based skills
	register_skill(MemorySkill.new(
		"Euphoria Surge",
		"joy",
		15,
		func(): PlayerData.heal(20)
	))
	
	# Trauma-based skills
	register_skill(MemorySkill.new(
		"Sorrow Strike",
		"trauma",
		20,
		func(): CombatSystem.deal_damage_to_enemy(30)
	))
	
	# Desire-based skills
	register_skill(MemorySkill.new(
		"Hunger Manifest",
		"desire",
		18,
		func(): CombatSystem.steal_enemy_resource(10)
	))
	
	# Anger-based skills
	register_skill(MemorySkill.new(
		"Wrath Unleashed",
		"anger",
		22,
		func(): CombatSystem.deal_damage_to_enemy(40)
	))
	
	# Hope-based skills
	register_skill(MemorySkill.new(
		"Beacon of Light",
		"hope",
		15,
		func(): PlayerData.heal(25)
	))
	
	# Regret-based skills
	register_skill(MemorySkill.new(
		"Temporal Echo",
		"regret",
		12,
		func(): CombatSystem.slow_enemy(2.0)
	))

func register_skill(skill: MemorySkill):
	memory_skills[skill.name] = skill

func get_skill(name: String) -> MemorySkill:
	return memory_skills.get(name, null)

func get_skills_by_type(memory_type: String) -> Array[MemorySkill]:
	var filtered: Array[MemorySkill] = []
	for skill_name in memory_skills:
		var skill = memory_skills[skill_name]
		if skill.memory_type == memory_type:
			filtered.append(skill)
	return filtered

func use_skill(skill_name: String) -> bool:
	var skill = get_skill(skill_name)
	if not skill:
		return false
	if skill.cooldown > 0:
		return false
	
	# Execute the skill effect
	skill.effect.call()
	skill.cooldown = 3.0  # Standard cooldown
	memory_skill_used.emit(skill_name, "executed")
	return true

# Memory Consumption - Permanent use of memory for powerful effect
func consume_memory_for_effect(memory_index: int) -> bool:
	var memory = PlayerData.consume_memory(memory_index)
	if memory.is_empty():
		return false
	
	# Apply effect based on memory type
	match memory["type"]:
		"trauma":
			CombatSystem.deal_damage_to_enemy(memory["power"] * 2)
		"desire":
			PlayerData.current_health = PlayerData.max_health
		"anger":
			CombatSystem.freeze_enemy(1.5)
		"joy":
			PlayerData.heal(memory["power"] * 3)
		"regret":
			CombatSystem.enemy_damage_self(memory["power"])
		_:
			PlayerData.heal(memory["power"])
	
	memory_consumed.emit(memory["type"])
	return true

# Puzzle System - Memories unlock puzzles
func register_puzzle(puzzle_name: String, required_memories: Array[String], reward_circle_progress: int):
	memory_puzzles[puzzle_name] = {
		"required_memories": required_memories,
		"solved": false,
		"reward_progress": reward_circle_progress
	}

func solve_puzzle(puzzle_name: String) -> bool:
	if puzzle_name not in memory_puzzles:
		return false
	
	var puzzle = memory_puzzles[puzzle_name]
	if puzzle["solved"]:
		return false
	
	# Check if player has required memories
	for required in puzzle["required_memories"]:
		var has_memory = false
		for memory in PlayerData.memories:
			if memory["type"] == required:
				has_memory = true
				break
		if not has_memory:
			return false
	
	# Solve the puzzle
	puzzle["solved"] = true
	solved_puzzles.append(puzzle_name)
	memory_puzzle_solved.emit(puzzle_name)
	
	# Award progress
	PlayerData.progress_circle(PlayerData.current_circle, puzzle["reward_progress"])
	return true

func can_solve_puzzle(puzzle_name: String) -> bool:
	if puzzle_name not in memory_puzzles:
		return false
	
	var puzzle = memory_puzzles[puzzle_name]
	if puzzle["solved"]:
		return false
	
	# Check if player has required memories
	for required in puzzle["required_memories"]:
		var has_memory = false
		for memory in PlayerData.memories:
			if memory["type"] == required:
				has_memory = true
				break
		if not has_memory:
			return false
	
	return true

func get_puzzle_info(puzzle_name: String) -> Dictionary:
	return memory_puzzles.get(puzzle_name, {})
