class_name EnemySpawner
extends Node2D

# Spawner settings
@export var spawn_interval: float = 2.5
@export var min_spawn_interval: float = 0.3
@export var spawn_decrease_rate: float = 0.01
@export var spawn_distance: float = 600.0
@export var max_enemies: int = 250

# Progressive difficulty
@export var enemies_per_spawn: int = 1
@export var spawn_increase_interval: float = 30.0

# Enemy and drop scenes
@export var enemy_scene: PackedScene
@export var xp_drop_scene: PackedScene
@export var health_drop_scene: PackedScene
@export var gold_drop_scene: PackedScene
@export var floating_score_scene: PackedScene
@export var loot_chest_scene: PackedScene

var player: Node2D = null
var spawn_timer: float = 0.0
var enemy_count: int = 0
var time_elapsed: float = 0.0
var last_increase_time: float = 0.0

func _ready() -> void:
	add_to_group("spawners")
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	time_elapsed += delta
	
	# Gradually spawn faster
	if spawn_interval > min_spawn_interval:
		spawn_interval -= spawn_decrease_rate * delta
	
	# Increase enemies per spawn over time
	if time_elapsed - last_increase_time >= spawn_increase_interval:
		enemies_per_spawn += 1
		last_increase_time = time_elapsed
		print("Spawn difficulty increased! Now spawning ", enemies_per_spawn, " enemies at once")
	
	# Spawn timer
	spawn_timer -= delta
	if spawn_timer <= 0 and enemy_count < max_enemies:
		_spawn_enemies()
		spawn_timer = spawn_interval

func _spawn_enemies() -> void:
	if enemy_scene == null:
		push_error("EnemySpawner: No enemy scene assigned!")
		return
	
	for i in enemies_per_spawn:
		if enemy_count >= max_enemies:
			break
		
		var enemy = enemy_scene.instantiate()
		
		# Pass drop scenes to enemy
		enemy.xp_drop_scene = xp_drop_scene
		enemy.health_drop_scene = health_drop_scene
		enemy.gold_drop_scene = gold_drop_scene
		enemy.floating_score_scene = floating_score_scene
		enemy.loot_chest_scene = loot_chest_scene
		
		# Spawn off-screen around player
		var angle = randf() * TAU
		var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
		enemy.global_position = spawn_pos
		
		# Add to world
		get_parent().add_child(enemy)
		enemy_count += 1
		
		# Track when enemy is removed
		enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	enemy_count -= 1
