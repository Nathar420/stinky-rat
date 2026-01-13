class_name StatsManager
extends Node

signal stat_changed(stat_name: String, old_value, new_value)
signal level_up(new_level: int)

# Experience and leveling
var current_xp: int = 0
var xp_to_next_level: int = 10
var player_level: int = 1

# Combat stats
var max_health: int = 100
var current_health: int = 100
var attack_speed_multiplier: float = 1.0
var movement_speed_multiplier: float = 1.0
var bonus_projectile_count: int = 0

# Progression
var current_gold: int = 0
var enemies_killed: int = 0
var current_score: int = 0

# Weapon levels - tracks upgrade count for each weapon
var weapon_levels: Dictionary = {}

var damage_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
var pickup_range_multiplier: float = 1.0
var projectile_speed_multiplier: float = 1.0
var area_size_multiplier: float = 1.0
var damage_reduction: float = 0.0

func _ready() -> void:
	current_health = max_health

func gain_xp(amount: int) -> void:
	current_xp += amount
	stat_changed.emit("xp", current_xp - amount, current_xp)
	
	while current_xp >= xp_to_next_level:
		_level_up()

func _level_up() -> void:
	player_level += 1
	current_xp -= xp_to_next_level
	xp_to_next_level = int(xp_to_next_level * 1.5)
	
	# Base stat increases per level
	attack_speed_multiplier += 0.1
	
	level_up.emit(player_level)

func take_damage(amount: int) -> void:
	var reduced_damage = int(amount * (1.0 - damage_reduction))
	var old_health = current_health
	current_health = max(0, current_health - reduced_damage)
	stat_changed.emit("health", old_health, current_health)

func heal(amount: int) -> void:
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	stat_changed.emit("health", old_health, current_health)

func increase_projectile_count(amount: int) -> void:
	bonus_projectile_count += amount
	stat_changed.emit("projectile_count", bonus_projectile_count - amount, bonus_projectile_count)
	
func add_gold(amount: int) -> void:
	var old_gold = current_gold
	current_gold += amount
	stat_changed.emit("gold", old_gold, current_gold)

func add_score(amount: int) -> void:
	var old_score = current_score
	current_score += amount
	stat_changed.emit("score", old_score, current_score)

func increment_kills() -> void:
	var old_kills = enemies_killed
	enemies_killed += 1
	stat_changed.emit("kills", old_kills, enemies_killed)

func increase_max_health(amount: int) -> void:
	max_health += amount
	heal(amount)  # Also heal by that amount
	
func increase_movement_speed(multiplier: float) -> void:
	movement_speed_multiplier += multiplier
	stat_changed.emit("movement_speed", movement_speed_multiplier - multiplier, movement_speed_multiplier)
	
func increase_damage(multiplier: float) -> void:
	damage_multiplier += multiplier
	stat_changed.emit("damage", damage_multiplier - multiplier, damage_multiplier)

func reduce_cooldown(multiplier: float) -> void:
	cooldown_multiplier -= multiplier
	if cooldown_multiplier < 0.3:  # Cap at 70% reduction
		cooldown_multiplier = 0.3
	stat_changed.emit("cooldown", cooldown_multiplier + multiplier, cooldown_multiplier)

func increase_pickup_range(multiplier: float) -> void:
	pickup_range_multiplier += multiplier
	stat_changed.emit("pickup_range", pickup_range_multiplier - multiplier, pickup_range_multiplier)

func increase_projectile_speed(multiplier: float) -> void:
	projectile_speed_multiplier += multiplier
	stat_changed.emit("projectile_speed", projectile_speed_multiplier - multiplier, projectile_speed_multiplier)

func increase_area_size(multiplier: float) -> void:
	area_size_multiplier += multiplier
	stat_changed.emit("area_size", area_size_multiplier - multiplier, area_size_multiplier)

func add_armor(reduction: float) -> void:
	damage_reduction += reduction
	if damage_reduction > 0.75:  # Cap at 75% reduction
		damage_reduction = 0.75
	stat_changed.emit("armor", damage_reduction - reduction, damage_reduction)
