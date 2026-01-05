class_name RicochetProjectile
extends Area2D

@export var speed: float = 600.0
@export var lifetime: float = 5.0
@export var max_bounces: int = 3
@export var max_ricochet_distance: float = 400.0
@export var damage_radius: float = 40.0

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
	
	_check_nearby_enemies()
	
	if has_node("bottlecap_animation"):
		$bottlecap_animation.rotation += delta * 10.0
	
	life_timer -= delta
	if life_timer <= 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body in hit_enemies:
			return
		
		if body.has_method("take_damage"):
			body.take_damage(10)
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
	
	var nearest: Node2D = null
	var nearest_distance: float = INF
	
	for enemy in valid_targets:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	
	if nearest:
		direction = global_position.direction_to(nearest.global_position)

func _check_nearby_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	
	for enemy in enemies:
		if enemy in hit_enemies:
			continue
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		
		if distance <= damage_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(10)
				hit_enemies.append(enemy)
				
				if bounces_remaining > 0:
					_ricochet_to_next_enemy()
				else:
					queue_free()
				return
