class_name EnemyRoach
extends CharacterBody2D

var last_damage_time: float = 0.0
@export var move_speed: float = 120.0
@export var health: int = 50
@export var contact_damage: int = 15
@export var score_value: int = 20

@export var xp_drop_chance: float = 0.20
@export var health_drop_chance: float = 0.01
@export var gold_drop_chance: float = 0.10
@export var chest_drop_chance: float = 0.02

var xp_drop_scene: PackedScene
var health_drop_scene: PackedScene
var gold_drop_scene: PackedScene
var loot_chest_scene: PackedScene
var floating_score_scene: PackedScene
var floating_damage_scene: PackedScene
var player: Node2D = null
var is_dying: bool = false

var is_confused: bool = false
var confusion_timer: float = 0.0
var target_enemy: Node2D = null
var retarget_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO
var is_knocked_back: bool = false

func _ready() -> void:
	add_to_group("enemies")
	
	# Create unique material copy for this enemy
	if has_node("roach_animation"):
		var sprite = $roach_animation
		if sprite.material:
			sprite.material = sprite.material.duplicate()
		sprite.play()
	
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_player_touched)
	else:
		print("ERROR: Roach has no Area2D!")
			
func _on_player_touched(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		print("Roach damaging player for ", contact_damage)
		body.take_damage(contact_damage, global_position)
		var knockback_direction = global_position.direction_to(body.global_position)
		knockback_velocity = knockback_direction * 300
		print("roach knocked back! Velocity: ", knockback_velocity)
		
func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
	
	if player == null or not is_instance_valid(player):
		return
	
	var distance_to_player = global_position.distance_squared_to(player.global_position)
	if distance_to_player > 1000000:
		return
	
	# Handle knockback FIRST
	if knockback_velocity.length() > 5.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.2)
		move_and_slide()
		
		if has_node("roach_animation"):
			$roach_animation.flip_h = velocity.x < 0
		return
	
	if is_confused:
		confusion_timer -= delta
		retarget_timer -= delta
		
		if confusion_timer <= 0:
			is_confused = false
			target_enemy = null
			if has_node("confusion_effect"):
				$confusion_effect.visible = false
	
	var target_position: Vector2
	if is_confused:
		if retarget_timer <= 0:
			target_enemy = _find_nearest_enemy_in_range()
			retarget_timer = 1.0
		
		if target_enemy and is_instance_valid(target_enemy):
			target_position = target_enemy.global_position
		else:
			target_position = player.global_position
	else:
		target_position = player.global_position
	
	var direction = global_position.direction_to(target_position)
	velocity = direction * move_speed
	move_and_slide()
	
	if is_confused:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider and is_instance_valid(collider) and collider.is_in_group("enemies") and collider != self:
				if collider.has_method("take_damage"):
					collider.take_damage(health)
	
	if has_node("roach_animation"):
		$roach_animation.flip_h = direction.x < 0

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

func take_damage(amount: int, is_crit: bool = false) -> void:
	if is_dying:
		return
	
	# Prevent duplicate damage in same frame
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_damage_time < 0.05:
		return
	last_damage_time = current_time
	
	health -= amount
	
	if floating_damage_scene:
		var damage_number = floating_damage_scene.instantiate()
		damage_number.global_position = global_position + Vector2(randf_range(-10, 10), -20)
		if damage_number.has_method("set_damage"):
			damage_number.set_damage(amount, is_crit)
		get_parent().add_child(damage_number)
	
	if health <= 0:
		_die()

func _die() -> void:
	is_dying = true
	velocity = Vector2.ZERO
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref:
		if player_ref.has_node("StatsManager"):
			player_ref.stats.add_score(score_value)
			player_ref.stats.increment_kills()
	
	if floating_score_scene:
		var floating_score = floating_score_scene.instantiate()
		floating_score.global_position = global_position
		if floating_score.has_method("set_score"):
			floating_score.set_score(score_value)
		get_parent().add_child(floating_score)
	
	_spawn_drops()
	
	if has_node("roach_animation"):
		if $roach_animation.sprite_frames.has_animation("death"):
			$roach_animation.play("death")
			await $roach_animation.animation_finished
		else:
			await get_tree().create_timer(0.5).timeout
	else:
		await get_tree().create_timer(0.5).timeout
	
	queue_free()

func _spawn_drops() -> void:
	if loot_chest_scene and randf() < chest_drop_chance:
		var chest = loot_chest_scene.instantiate()
		chest.global_position = global_position
		get_parent().add_child(chest)
		return
	
	if xp_drop_scene and randf() < xp_drop_chance:
		var xp = xp_drop_scene.instantiate()
		xp.global_position = global_position
		get_parent().add_child(xp)
	
	if health_drop_scene and randf() < health_drop_chance:
		var health = health_drop_scene.instantiate()
		health.global_position = global_position + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		get_parent().add_child(health)
	
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
