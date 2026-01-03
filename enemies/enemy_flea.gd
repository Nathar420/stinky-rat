class_name EnemyFlea
extends CharacterBody2D

@export var move_speed: float = 150.0
@export var health: int = 30
@export var contact_damage: int = 10
@export var score_value: int = 10

# Drop chances
@export var xp_drop_chance: float = 0.20
@export var health_drop_chance: float = 0.01
@export var gold_drop_chance: float = 0.10
@export var chest_drop_chance: float = 0.02

# Drop scenes (set by spawner)
var xp_drop_scene: PackedScene
var health_drop_scene: PackedScene
var gold_drop_scene: PackedScene
var loot_chest_scene: PackedScene
var floating_score_scene: PackedScene

var player: Node2D = null
var is_dying: bool = false

# Confusion mechanics
var is_confused: bool = false
var confusion_timer: float = 0.0
var target_enemy: Node2D = null
var retarget_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemies")
	
	# Play animation if exists
	if has_node("flea_animation"):
		$flea_animation.play("flea_jump")
	
	# Setup collision damage
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_player_touched)

func _on_player_touched(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(contact_damage)

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	# Get player reference
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	# Skip distant enemies for performance
	var distance_to_player = global_position.distance_squared_to(player.global_position)
	if distance_to_player > 1000000:  # ~1000 pixels
		return
	
	# Handle confusion
	if is_confused:
		confusion_timer -= delta
		retarget_timer -= delta
		
		if confusion_timer <= 0:
			is_confused = false
			target_enemy = null
			if has_node("confusion_effect"):
				$confusion_effect.visible = false
	
	# Determine target
	var target_position: Vector2
	if is_confused:
		if retarget_timer <= 0:
			target_enemy = _find_nearest_enemy_in_range()
			retarget_timer = 1.0
		
		if target_enemy and is_instance_valid(target_enemy):
			target_position = target_enemy.global_position
		else:
			return
	else:
		target_position = player.global_position
	
	# Move towards target
	var direction = global_position.direction_to(target_position)
	velocity = direction * move_speed
	move_and_slide()
	
	# Handle confused collision with other enemies
	if is_confused:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("enemies") and collider != self:
				if collider.has_method("take_damage"):
					collider.take_damage(health)  # Kill them instantly
	
	# Flip sprite
	if has_node("flea_animation"):
		$flea_animation.flip_h = direction.x < 0

func _find_nearest_enemy_in_range() -> Node2D:
	var search_radius: float = 150.0
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_distance: float = search_radius
	
	for enemy in enemies:
		if enemy == self or not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	
	return nearest

func take_damage(amount: int) -> void:
	if is_dying:
		return
	
	health -= amount
	
	if health <= 0:
		_die()

func _die() -> void:
	is_dying = true
	velocity = Vector2.ZERO
	
	# Disable collision
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	# Award score and kill to player
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		if player_ref.has_method("add_score"):
			player_ref.add_score(score_value)
		elif player_ref.has_node("StatsManager"):
			player_ref.stats.add_score(score_value)
			player_ref.stats.increment_kills()
	
	# Spawn floating score
	if floating_score_scene:
		var floating_score = floating_score_scene.instantiate()
		floating_score.global_position = global_position
		if floating_score.has_method("set_score"):
			floating_score.set_score(score_value)
		get_parent().add_child(floating_score)
	
	# Spawn drops
	_spawn_drops()
	
	# Play death animation
	if has_node("flea_animation"):
		$flea_animation.play("flea_death")
		await $flea_animation.animation_finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	queue_free()

func _spawn_drops() -> void:
	# Chest drop (highest priority)
	if loot_chest_scene and randf() < chest_drop_chance:
		var chest = loot_chest_scene.instantiate()
		chest.global_position = global_position
		get_parent().add_child(chest)
		return  # Don't drop other items if chest drops
	
	# XP drop
	if xp_drop_scene and randf() < xp_drop_chance:
		var xp = xp_drop_scene.instantiate()
		xp.global_position = global_position
		get_parent().add_child(xp)
	
	# Health drop
	if health_drop_scene and randf() < health_drop_chance:
		var health = health_drop_scene.instantiate()
		health.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_parent().add_child(health)
	
	# Gold drop
	if gold_drop_scene and randf() < gold_drop_chance:
		var gold = gold_drop_scene.instantiate()
		gold.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_parent().add_child(gold)

func confuse(duration: float) -> void:
	is_confused = true
	confusion_timer = duration
	retarget_timer = 0.0
	
	if has_node("confusion_effect"):
		$confusion_effect.visible = true
		if $confusion_effect.has_method("play"):
			$confusion_effect.play()
