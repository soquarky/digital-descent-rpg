extends Node

## Memory fragment database and collection system
## Each fragment represents a recovered piece of Steven/Melody's story

var fragment_database: Dictionary = {}
var collected_fragments: Array[String] = []

signal fragment_spawned(fragment_id: String, position: Vector2)
signal collection_milestone(percentage: float)

func _ready():
	_initialize_fragment_database()
	print("[MemorySystem] Initialized with ", fragment_database.size(), " fragments")

func _initialize_fragment_database():
	"""Define all memory fragments in the game"""
	# Circle 1 - Limbo fragments
	fragment_database["limbo_undiagnosed"] = {
		"title": "Before the Diagnosis",
		"description": "Years of doctors saying 'it's just stress'",
		"pathway": "investigation",
		"circle": 1,
		"emotional_weight": 0.3
	}
	
	fragment_database["limbo_childhood"] = {
		"title": "The Missing Years",
		"description": "Gaps in time, explained away by adults",
		"pathway": "intuition",
		"circle": 1,
		"emotional_weight": 0.4
	}
	
	# Circle 2 - Lust fragments
	fragment_database["lust_predator"] = {
		"title": "The Voyeur",
		"description": "Eyes that watched too long, too closely",
		"pathway": "empathy",
		"circle": 2,
		"emotional_weight": 0.7
	}
	
	# Circle 3 - Gluttony fragments
	fragment_database["gluttony_attention"] = {
		"title": "Career Opportunity",
		"description": "Your pain became someone's publication",
		"pathway": "logic",
		"circle": 3,
		"emotional_weight": 0.6
	}
	
	# Add more fragments for each circle...

func spawn_fragment(fragment_id: String, world_position: Vector2):
	"""Create a memory fragment pickup in the world"""
	if fragment_id not in fragment_database:
		print("[ERROR] Unknown fragment: ", fragment_id)
		return
	
	fragment_spawned.emit(fragment_id, world_position)

func collect_fragment(fragment_id: String) -> bool:
	"""Player collects a fragment"""
	if fragment_id in collected_fragments:
		return false
	
	if fragment_id not in fragment_database:
		return false
	
	collected_fragments.append(fragment_id)
	var fragment = fragment_database[fragment_id]
	
	# Add to player data
	PlayerData.add_memory_fragment(fragment_id, fragment)
	
	# Strengthen associated neural pathway
	var pathway = fragment["pathway"]
	PlayerData.strengthen_neural_pathway(pathway, 1)
	
	# Check for milestones
	var percentage = (float(collected_fragments.size()) / fragment_database.size()) * 100.0
	if int(percentage) % 10 == 0:  # Every 10%
		collection_milestone.emit(percentage)
	
	print("[MemorySystem] Fragment collected: ", fragment["title"])
	return true

func get_fragment_data(fragment_id: String) -> Dictionary:
	"""Retrieve fragment information"""
	return fragment_database.get(fragment_id, {})

func get_circle_fragments(circle: int) -> Array[String]:
	"""Get all fragment IDs for a specific circle"""
	var result: Array[String] = []
	for fid in fragment_database.keys():
		if fragment_database[fid]["circle"] == circle:
			result.append(fid)
	return result

func get_collection_percentage() -> float:
	"""Overall completion percentage"""
	return (float(collected_fragments.size()) / fragment_database.size()) * 100.0