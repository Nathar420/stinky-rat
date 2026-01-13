class_name Explosion
extends Area2D

@export var explosion_radius: float = 100.0
@export var damage: int = 30
@export var lifetime: float = 0.6

func _ready() -> void:
	add_to_group("explosions")
	
	if has_node("CollisionShape2D"):
		var shape = $CollisionShape2D.shape as CircleShape2D
		if shape:
			shape.radius = explosion_radius
	
	_damage_enemies()
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")
		await $AnimatedSprite2D.animation_finished
		queue_free()
	elif has_node("AnimationPlayer"):
		$AnimationPlayer.play("explode")
		await get_tree().create_timer(lifetime).timeout
		queue_free()
	else:
		await get_tree().create_timer(lifetime).timeout
		queue_free()

func _damage_enemies() -> void:
	await get_tree().process_frame
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hit_count = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		# Cache the position in case enemy dies during this frame
		var enemy_pos = enemy.global_position
		var distance = global_position.distance_to(enemy_pos)
		
		if distance <= explosion_radius:
			# Check validity again right before dealing damage
			if is_instance_valid(enemy) and enemy.has_method("take_damage"):
				enemy.take_damage(damage)
				hit_count += 1
	
	print("Explosion hit ", hit_count, " enemies")
