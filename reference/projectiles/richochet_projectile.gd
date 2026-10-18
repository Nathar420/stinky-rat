class_name RicochetProjectile
extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 5.0
@export var max_bounces: int = 3
@export var max_ricochet_distance: float = 400.0
@export var damage: int = 25

var direction: Vector2 = Vector2.ZERO
var life_timer: float = 0.0
var bounces_remaining: int = 0
var hit_enemies: Array = []

func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)
	life_timer = lifetime
	bounces_remaining = max_bounces
	
	if has_node("bottlecap_animation"):
		$bottlecap_animation.play()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	if has_node("bottlecap_animation"):
		$bottlecap_animation.rotation += delta * 10.0
	
	life_timer -= delta
	if life_timer <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	
	if body in hit_enemies:
		return
	
	if not body.has_method("take_damage"):
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("StatsManager"):
		var damage_result = player.stats.calculate_damage(damage)
		body.take_damage(damage_result.damage, damage_result.is_crit)
	else:
		body.take_damage(damage, false)
	
	hit_enemies.append(body)
	
	if bounces_remaining > 0:
		_ricochet_to_next_enemy()
	else:
		queue_free()

func _ricochet_to_next_enemy() -> void:
	bounces_remaining -= 1
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var valid_targets: Array = []
	
	for enemy in enemies:
		if enemy in hit_enemies:
			continue
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= max_ricochet_distance:
			valid_targets.append(enemy)
	
	if valid_targets.is_empty():
		queue_free()
		return
	
	var target: Node2D = null
	
	if valid_targets.size() <= 2:
		target = valid_targets[randi() % valid_targets.size()]
	else:
		var sorted_enemies = []
		for enemy in valid_targets:
			var distance = global_position.distance_to(enemy.global_position)
			sorted_enemies.append({"enemy": enemy, "distance": distance})
		
		sorted_enemies.sort_custom(func(a, b): return a.distance < b.distance)
		
		var pool_size = min(5, sorted_enemies.size())
		var random_index = randi() % pool_size
		target = sorted_enemies[random_index].enemy
	
	if target:
		direction = global_position.direction_to(target.global_position)
