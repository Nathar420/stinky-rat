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
	var basic_gun = ItemData.new()
	basic_gun.id = "basic_gun"
	basic_gun.display_name = "Upgraded Slingshot"
	basic_gun.description = "Fire more projectiles from your basic weapon"
	basic_gun.item_type = ItemData.ItemType.WEAPON
	basic_gun.max_level = 10
	all_items.append(basic_gun)
	
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
	
	# CHEST-ONLY PASSIVE ITEMS
	var damage_boost = ItemData.new()
	damage_boost.id = "damage_boost"
	damage_boost.display_name = "Rat Rage"
	damage_boost.description = "Increases all damage by 20%"
	damage_boost.item_type = ItemData.ItemType.PASSIVE
	damage_boost.max_level = 5
	damage_boost.chest_only = true
	all_items.append(damage_boost)
	
	var cooldown_reduction = ItemData.new()
	cooldown_reduction.id = "cooldown_reduction"
	cooldown_reduction.display_name = "Rusty Watch"
	cooldown_reduction.description = "Reduces all ability cooldowns by 10%"
	cooldown_reduction.item_type = ItemData.ItemType.PASSIVE
	cooldown_reduction.max_level = 5
	cooldown_reduction.chest_only = true
	all_items.append(cooldown_reduction)
	
	var pickup_range = ItemData.new()
	pickup_range.id = "pickup_range"
	pickup_range.display_name = "Magnet"
	pickup_range.description = "Increases pickup range for items by 30%"
	pickup_range.item_type = ItemData.ItemType.PASSIVE
	pickup_range.max_level = 5
	pickup_range.chest_only = true
	all_items.append(pickup_range)
	
	var projectile_speed = ItemData.new()
	projectile_speed.id = "projectile_speed"
	projectile_speed.display_name = "Energy Drink"
	projectile_speed.description = "Increases projectile speed by 15%"
	projectile_speed.item_type = ItemData.ItemType.PASSIVE
	projectile_speed.max_level = 5
	projectile_speed.chest_only = true
	all_items.append(projectile_speed)
	
	var area_size = ItemData.new()
	area_size.id = "area_size"
	area_size.display_name = "Magnifying Glass"
	area_size.description = "Increases area of effect by 15%"
	area_size.item_type = ItemData.ItemType.PASSIVE
	area_size.max_level = 5
	area_size.chest_only = true
	all_items.append(area_size)
	
	var armor = ItemData.new()
	armor.id = "armor"
	armor.display_name = "Cardboard Armor"
	armor.description = "Reduces damage taken by 10%"
	armor.item_type = ItemData.ItemType.PASSIVE
	armor.max_level = 5
	armor.chest_only = true
	all_items.append(armor)
	
	var projectile_count = ItemData.new()
	projectile_count.id = "projectile_count"
	projectile_count.display_name = "Split Shot"
	projectile_count.description = "All weapons fire +1 additional projectile"
	projectile_count.item_type = ItemData.ItemType.PASSIVE
	projectile_count.max_level = 5
	all_items.append(projectile_count)
	
	var crit_chance_item = ItemData.new()
	crit_chance_item.id = "crit_chance"
	crit_chance_item.display_name = "Lucky Coin"
	crit_chance_item.description = "Increases critical hit chance by 10%"
	crit_chance_item.item_type = ItemData.ItemType.PASSIVE
	crit_chance_item.max_level = 5
	crit_chance_item.chest_only = true
	all_items.append(crit_chance_item)
	
	var crit_damage_item = ItemData.new()
	crit_damage_item.id = "crit_damage"
	crit_damage_item.display_name = "Sharp Claw"
	crit_damage_item.description = "Increases critical damage by 25%"
	crit_damage_item.item_type = ItemData.ItemType.PASSIVE
	crit_damage_item.max_level = 5
	crit_damage_item.chest_only = true
	all_items.append(crit_damage_item)
	
func get_random_chest_item(stats: StatsManager) -> ItemData:
	var available: Array[ItemData] = []
	
	for item in all_items:
		# Only include chest-only items
		if not item.chest_only:
			continue
		
		var current_level = stats.weapon_levels.get(item.id, 0)
		if current_level < item.max_level:
			available.append(item)
	
	if available.is_empty():
		return null
	
	return available[randi() % available.size()]
	
func get_random_upgrades(count: int, stats: StatsManager) -> Array[ItemData]:
	var available: Array[ItemData] = []
	
	for item in all_items:
		# Skip chest-only items in level-ups
		if item.chest_only:
			continue
		
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
