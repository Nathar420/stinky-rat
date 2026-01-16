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
	
	var player = get_tree().get_first_node_in_group("player")
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var enemy_pos = enemy.global_position
		var distance = global_position.distance_to(enemy_pos)
		
		if distance <= explosion_radius:
			if is_instance_valid(enemy) and enemy.has_method("take_damage"):
				if player and player.has_node("StatsManager"):
					var damage_result = player.stats.calculate_damage(damage)
					enemy.take_damage(damage_result.damage, damage_result.is_crit)
				else:
					enemy.take_damage(damage, false)
				hit_count += 1
	
	print("Explosion hit ", hit_count, " enemies")
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		# More hits = more shake
		var shake_intensity = 2.0 + (hit_count * 0.3)
		camera.add_shake(shake_intensity)
