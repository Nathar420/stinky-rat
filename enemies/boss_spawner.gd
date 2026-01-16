class_name BossSpawner
extends Node2D

@export var boss_scene: PackedScene
@export var spawn_time: float = 420.0  # 7 minutes (7 * 60 = 420 seconds)
@export var spawn_distance: float = 700.0

@export var xp_drop_scene: PackedScene
@export var health_drop_scene: PackedScene
@export var gold_drop_scene: PackedScene
@export var floating_score_scene: PackedScene
@export var floating_damage_scene: PackedScene
@export var enemy_flea_scene: PackedScene

var player: Node2D = null
var has_spawned: bool = false
var game_time: float = 0.0

func _ready() -> void:
	add_to_group("spawners")
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if has_spawned:
		return
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		return
	
	game_time += delta
	
	if game_time >= spawn_time:
		_spawn_boss()
		has_spawned = true

func _spawn_boss() -> void:
	if boss_scene == null:
		push_error("BossSpawner: No boss scene assigned!")
		return
	
	print("=== BOSS CAT SPAWNING! ===")
	
	var boss = boss_scene.instantiate()
	
	boss.xp_drop_scene = xp_drop_scene
	boss.health_pickup_scene = health_drop_scene
	boss.gold_pickup_scene = gold_drop_scene
	boss.floating_score_scene = floating_score_scene
	boss.floating_damage_scene = floating_damage_scene
	boss.enemy_flea_scene = enemy_flea_scene
	
	var angle = randf() * TAU
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * spawn_distance
	
	get_parent().add_child(boss)
	boss.global_position = spawn_pos
	
	print("Boss Cat spawned at: ", spawn_pos, " after ", game_time, " seconds!")
