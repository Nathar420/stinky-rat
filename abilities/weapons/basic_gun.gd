class_name BasicGun
extends BaseAbility

@export var projectile_scene: PackedScene
@export var projectiles_per_shot: int = 1
@export var spread_angle: float = 0.3

func _on_initialized() -> void:
	ability_name = "Basic Gun"
	base_cooldown = 0.5

func _execute_ability() -> void:
	var nearest_enemy = _find_nearest_enemy()
	if nearest_enemy == null:
		return
	
	_shoot_at_target(nearest_enemy)

func _shoot_at_target(target: Node2D) -> void:
	if projectile_scene == null:
		push_error("BasicGun: No projectile scene assigned!")
		return
	
	var base_direction = player.global_position.direction_to(target.global_position)
	
	for i in range(projectiles_per_shot):
		var projectile = projectile_scene.instantiate()
		projectile.global_position = player.global_position
		
		# Calculate spread
		var angle_offset = 0.0
		if projectiles_per_shot > 1:
			var total_spread = spread_angle
			angle_offset = -total_spread / 2 + (total_spread / (projectiles_per_shot - 1)) * i
		
		projectile.direction = base_direction.rotated(angle_offset)
		
		# Add to world (not to player)
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
	# Each level adds 1 more projectile
	projectiles_per_shot += 1
	print("Basic Gun leveled up! Now shoots ", projectiles_per_shot, " projectiles")
