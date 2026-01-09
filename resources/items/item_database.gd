class_name ItemDatabase
extends Node


enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

var rarity_weights = {
	Rarity.COMMON: 50,
	Rarity.UNCOMMON: 30,
	Rarity.RARE: 15,
	Rarity.EPIC: 4,
	Rarity.LEGENDARY: 1
}

var rarity_colors = {
	Rarity.COMMON: Color(0.8, 0.8, 0.8),
	Rarity.UNCOMMON: Color(0.2, 0.8, 0.2),
	Rarity.RARE: Color(0.3, 0.5, 1.0),
	Rarity.EPIC: Color(0.7, 0.3, 1.0),
	Rarity.LEGENDARY: Color(1.0, 0.8, 0.0)
}
var all_items: Array[ItemData] = []

func _ready() -> void:
	_initialize_items()

func _initialize_items() -> void:
	all_items.clear()
	
	# WEAPONS
	var ricochet = ItemData.new()
	ricochet.id = "ricochet"
	ricochet.display_name = "Ricochet Bottle Cap"
	ricochet.description = "Throws a bottle cap that bounces between enemies"
	ricochet.item_type = ItemData.ItemType.WEAPON
	ricochet.max_level = 10
	all_items.append(ricochet)
	
	var explosion = ItemData.new()
	explosion.id = "explosion"
	explosion.display_name = "Explosive Flask"
	explosion.description = "Creates explosions that damage nearby enemies"
	explosion.item_type = ItemData.ItemType.WEAPON
	explosion.max_level = 10
	all_items.append(explosion)
	
	var sword = ItemData.new()
	sword.id = "sword"
	sword.display_name = "Rusty Sword"
	sword.description = "Swings a sword in front of you"
	sword.item_type = ItemData.ItemType.WEAPON
	sword.max_level = 10
	all_items.append(sword)
	
	var spoon = ItemData.new()
	spoon.id = "spoon"
	spoon.display_name = "Confusion Spoon"
	spoon.description = "Confuses enemies in a burst around you"
	spoon.item_type = ItemData.ItemType.WEAPON
	spoon.max_level = 10
	all_items.append(spoon)
	
	# PASSIVE ITEMS
	var speed = ItemData.new()
	speed.id = "speed_boost"
	speed.display_name = "Spray-On Shoes"
	speed.description = "Increases movement speed by 25%"
	speed.item_type = ItemData.ItemType.PASSIVE
	speed.max_level = 5
	all_items.append(speed)
	
	var health = ItemData.new()
	health.id = "max_health"
	health.display_name = "Grilled Cheese"
	health.description = "Increases max health by 20"
	health.item_type = ItemData.ItemType.PASSIVE
	health.max_level = 10
	all_items.append(health)

func get_random_chest_item(stats: StatsManager) -> ItemData:
	var available: Array[ItemData] = []
	
	for item in all_items:
		var current_level = stats.weapon_levels.get(item.id, 0)
		if current_level < item.max_level:
			available.append(item)
	
	if available.is_empty():
		return null
	
	# For now just pick randomly, you can add rarity weighting later
	return available[randi() % available.size()]
	
func get_random_upgrades(count: int, stats: StatsManager) -> Array[ItemData]:
	var available: Array[ItemData] = []
	
	for item in all_items:
		var current_level = stats.weapon_levels.get(item.id, 0)
		if current_level < item.max_level:
			available.append(item)
	
	if available.is_empty():
		return []
	
	available.shuffle()
	var result: Array[ItemData] = []
	for i in range(min(count, available.size())):
		result.append(available[i])
	
	return result

func get_item_by_id(item_id: String) -> ItemData:
	for item in all_items:
		if item.id == item_id:
			return item
	return null
