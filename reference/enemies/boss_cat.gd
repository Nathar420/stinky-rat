class_name BossCat
extends CharacterBody2D

@export var max_health: int = 500
@export var contact_damage: int = 20
@export var score_reward: int = 10000

@export var chase_speed: float = 100.0
@export var keep_distance: float = 200.0
@export var lunge_speed: float = 400.0
@export var lunge_cooldown: float = 3.0
@export var lunge_duration: float = 0.8
@export var windup_time: float = 0.3

@export var fleas_per_spawn: int = 10
@export var flea_spawn_cooldown: float = 10.0
@export var xp_drops_count: int = 5
@export var gold_drops_count: int = 8
@export var health_drops_count: int = 3

@export var enemy_flea_scene: PackedScene
@export var xp_drop_scene: PackedScene
@export var gold_pickup_scene: PackedScene
@export var health_pickup_scene: PackedScene
@export var floating_score_scene: PackedScene
@export var floating_damage_scene: PackedScene

var current_health: int
var player: Node2D = null
var is_dying: bool = false
var is_lunging: bool = false
var lunge_timer: float = 0.0
var lunge_direction: Vector2 = Vector2.ZERO
var damage_cooldown: float = 0.0
var flea_spawn_timer: float = 0.0
var last_damage_time: float = 0.0

var flea_spawn_health_75: bool = false
var flea_spawn_health_50: bool = false
var flea_spawn_health_25: bool = false

func _ready() -> void:
	add_to_group("enemies")
	current_health = max_health
	flea_spawn_timer = flea_spawn_cooldown
	lunge_timer = lunge_cooldown
	
	if has_node("cat_animation"):
		$cat_animation.play("can_walk")
	
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_player_touched)

func _on_player_touched(body: Node2D) -> void:
	if body.is_in_group("player") and damage_cooldown <= 0:
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)
			damage_cooldown = 0.5
			print("Boss hit player for ", contact_damage, " damage!")

func _physics_process(delta: float) -> void:
	if is_dying:
		return
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
	
	flea_spawn_timer -= delta
	if flea_spawn_timer <= 0:
		_spawn_fleas()
		flea_spawn_timer = flea_spawn_cooldown
	
	damage_cooldown -= delta
	
	if not is_lunging:
		lunge_timer -= delta
	
	if lunge_timer <= 0 and not is_lunging:
		_start_lunge()
	
	if is_lunging:
		velocity = lunge_direction * lunge_speed
	else:
		_chase_movement()
	
	move_and_slide()
	
	if has_node("cat_animation"):
		if velocity.x < 0:
			$cat_animation.flip_h = true
		elif velocity.x > 0:
			$cat_animation.flip_h = false

func _chase_movement() -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction = global_position.direction_to(player.global_position)
	
	if distance_to_player > keep_distance:
		velocity = direction * chase_speed
	else:
		var perpendicular = Vector2(-direction.y, direction.x)
		velocity = perpendicular * chase_speed * 0.5

func _start_lunge() -> void:
	if has_node("cat_animation"):
		$cat_animation.play("lunge")
	
	await get_tree().create_timer(windup_time).timeout
	
	is_lunging = true
	lunge_direction = global_position.direction_to(player.global_position)
	
	await get_tree().create_timer(lunge_duration - windup_time).timeout
	
	is_lunging = false
	lunge_timer = lunge_cooldown
	
	if has_node("cat_animation"):
		$cat_animation.play("cat_walk")

func take_damage(amount: int, is_crit: bool = false) -> void:
	if is_dying:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_damage_time < 0.05:
		return
	last_damage_time = current_time
	
	current_health -= amount
	
	if floating_damage_scene:
		var damage_number = floating_damage_scene.instantiate()
		damage_number.global_position = global_position + Vector2(randf_range(-30, 30), -40)
		if damage_number.has_method("set_damage"):
			damage_number.set_damage(amount, is_crit)
		get_parent().add_child(damage_number)
	
	if has_node("cat_animation"):
		var anim = $cat_animation
		anim.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(self):
			anim.modulate = Color.WHITE
	
	var health_percent = float(current_health) / float(max_health)
	
	if health_percent <= 0.75 and not flea_spawn_health_75:
		flea_spawn_health_75 = true
		_spawn_fleas()
	
	if health_percent <= 0.50 and not flea_spawn_health_50:
		flea_spawn_health_50 = true
		_spawn_fleas()
	
	if health_percent <= 0.25 and not flea_spawn_health_25:
		flea_spawn_health_25 = true
		_spawn_fleas()
	
	if current_health <= 0:
		_die()

func _spawn_fleas() -> void:
	if enemy_flea_scene == null:
		return
	
	print("Boss spawning ", fleas_per_spawn, " fleas!")
	
	for i in range(fleas_per_spawn):
		var flea = enemy_flea_scene.instantiate()
		
		flea.xp_drop_scene = xp_drop_scene
		flea.floating_score_scene = floating_score_scene
		flea.health_drop_scene = health_pickup_scene
		flea.gold_drop_scene = gold_pickup_scene
		flea.floating_damage_scene = floating_damage_scene
		
		var angle = (TAU / fleas_per_spawn) * i
		var leap_direction = Vector2(cos(angle), sin(angle))
		var spawn_offset = leap_direction * 50.0
		
		get_parent().add_child(flea)
		flea.global_position = global_position + spawn_offset
		
		_make_flea_leap(flea, leap_direction)

func _make_flea_leap(flea: CharacterBody2D, direction: Vector2) -> void:
	if has_node("cat_animation"):
		$cat_animation.play("shake")
	
	var leap_distance = 200.0
	var leap_duration = 0.8
	var target_pos = flea.global_position + (direction * leap_distance)
	
	var tween = create_tween()
	tween.tween_property(flea, "global_position", target_pos, leap_duration)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)

func _die() -> void:
	if is_dying:
		return
	
	is_dying = true
	velocity = Vector2.ZERO
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	var player_ref = get_tree().get_first_node_in_group("player")
	if player_ref and player_ref.has_node("StatsManager"):
		player_ref.stats.add_score(score_reward)
		player_ref.stats.increment_kills()
	
	if floating_score_scene:
		var floating_score = floating_score_scene.instantiate()
		floating_score.global_position = global_position
		if floating_score.has_method("set_score"):
			floating_score.set_score(score_reward)
		get_parent().add_child(floating_score)
	
	_spawn_loot()
	
	if has_node("cat_animation"):
		$cat_animation.play("death")
		if $cat_animation.sprite_frames.has_animation("death"):
			await $cat_animation.animation_finished
		else:
			await get_tree().create_timer(1.0).timeout
	else:
		await get_tree().create_timer(1.0).timeout
	
	queue_free()

func _spawn_loot() -> void:
	if xp_drop_scene:
		for i in range(xp_drops_count):
			var xp = xp_drop_scene.instantiate()
			var random_offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			get_parent().add_child(xp)
			xp.global_position = global_position + random_offset
	
	if gold_pickup_scene:
		for i in range(gold_drops_count):
			var gold = gold_pickup_scene.instantiate()
			var random_offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			get_parent().add_child(gold)
			gold.global_position = global_position + random_offset
	
	if health_pickup_scene:
		for i in range(health_drops_count):
			var health = health_pickup_scene.instantiate()
			var random_offset = Vector2(randf_range(-80, 80), randf_range(-80, 80))
			get_parent().add_child(health)
			health.global_position = global_position + random_offset
	
	print("Boss dropped loot!")
