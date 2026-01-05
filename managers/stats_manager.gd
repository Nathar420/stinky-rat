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

# Progression
var current_gold: int = 0
var enemies_killed: int = 0
var current_score: int = 0

# Weapon levels - tracks upgrade count for each weapon
var weapon_levels: Dictionary = {}

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
	var old_health = current_health
	current_health = max(0, current_health - amount)
	stat_changed.emit("health", old_health, current_health)

func heal(amount: int) -> void:
	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	stat_changed.emit("health", old_health, current_health)

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
