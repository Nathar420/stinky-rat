class_name RicochetGun
extends BaseAbility

@export var projectile_scene: PackedScene
@export var projectiles_per_shot: int = 1
@export var bounces_per_projectile: int = 3

func _on_initialized() -> void:
	ability_name = "Ricochet Gun"
	base_cooldown = 2.0

func _execute_ability() -> void:
	var nearest_enemy = _find_nearest_enemy()
	if nearest_enemy == null:
		return
	
	_shoot_ricochet(nearest_enemy)

func _shoot_ricochet(target: Node2D) -> void:
	if projectile_scene == null:
		push_error("RicochetGun: No projectile scene assigned!")
		return
	
	var base_direction = player.global_position.direction_to(target.global_position)
	
	for i in range(projectiles_per_shot):
		var projectile = projectile_scene.instantiate()
		projectile.global_position = player.global_position
		
		var spread_angle = 0.0
		if projectiles_per_shot > 1:
			var total_spread = 0.3
			spread_angle = -total_spread / 2 + (total_spread / (projectiles_per_shot - 1)) * i
		
		projectile.direction = base_direction.rotated(spread_angle)
		projectile.max_bounces = bounces_per_projectile
		projectile.bounces_remaining = bounces_per_projectile
		
		player.get_parent().add_child(projectile)

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var nearest: Node2D = null
	var nearest_distance: float = INF
	
	for enemy in enemies:
		var distance = player.global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = enemy
	
	return nearest

func _on_level_up() -> void:
	projectiles_per_shot += 1
	print("Ricochet Gun leveled up! Now shoots ", projectiles_per_shot, " projectiles with ", bounces_per_projectile, " bounces each")
