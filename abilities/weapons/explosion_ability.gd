class_name ExplosionAbility
extends BaseAbility

@export var explosion_scene: PackedScene
@export var explosions_per_use: int = 1
@export var explosion_spread: float = 50.0

func _on_initialized() -> void:
	ability_name = "Explosion Flask"
	base_cooldown = 3.5

func _execute_ability() -> void:
	var best_target = _find_best_explosion_target()
	if best_target:
		_create_explosions_at(best_target)

func _create_explosions_at(target_position: Vector2) -> void:
	if explosion_scene == null:
		push_error("ExplosionAbility: No explosion scene assigned!")
		return
	
	# Get list of targets from the cluster
	var targets = _find_spread_targets_in_cluster(explosions_per_use)
	
	if targets.is_empty():
		# Fallback to original position if no targets
		var explosion = explosion_scene.instantiate()
		player.get_parent().add_child(explosion)
		explosion.global_position = target_position
		return
	
	# Create explosions at each target
	for i in range(targets.size()):
		var explosion = explosion_scene.instantiate()
		player.get_parent().add_child(explosion)
		explosion.global_position = targets[i].global_position
		
		if i < targets.size() - 1:
			await get_tree().create_timer(0.2).timeout

func _find_best_explosion_target() -> Vector2:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return Vector2.ZERO
	
	var viewport = get_viewport()
	var camera = viewport.get_camera_2d()
	var screen_rect = Rect2()
	
	if camera:
		var viewport_size = viewport.get_visible_rect().size
		var camera_pos = camera.get_screen_center_position()
		screen_rect = Rect2(camera_pos - viewport_size / 2, viewport_size)
	
	var on_screen_enemies: Array = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position == Vector2.ZERO:
			continue
		if camera and screen_rect.has_point(enemy.global_position):
			on_screen_enemies.append(enemy)
	
	# CHANGED: Only use on-screen enemies, or fall back to nearest
	if on_screen_enemies.is_empty():
		var nearest = _find_nearest_enemy()
		if nearest:
			return nearest.global_position
		return Vector2.ZERO
	
	var best_position: Vector2 = Vector2.ZERO
	var max_enemies_hit: int = 0
	var explosion_range: float = 100.0
	
	for potential_center in on_screen_enemies:
		if not is_instance_valid(potential_center):
			continue
		
		var enemies_in_range: int = 0
		
		for enemy in on_screen_enemies:
			if not is_instance_valid(enemy):
				continue
			var distance = potential_center.global_position.distance_to(enemy.global_position)
			if distance <= explosion_range:
				enemies_in_range += 1
		
		if enemies_in_range > max_enemies_hit:
			max_enemies_hit = enemies_in_range
			best_position = potential_center.global_position
	
	return best_position

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
func _find_spread_targets_in_cluster(count: int) -> Array:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return []
	
	# Find the center of the largest cluster
	var cluster_center = _find_best_explosion_target()
	if cluster_center == Vector2.ZERO:
		return []
	
	# Get enemies in that cluster
	var cluster_radius = 150.0
	var enemies_in_cluster: Array = []
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		var distance = enemy.global_position.distance_to(cluster_center)
		if distance <= cluster_radius:
			enemies_in_cluster.append(enemy)
	
	if enemies_in_cluster.is_empty():
		return []
	
	# Sort by how many neighbors each enemy has (prioritize dense areas)
	var scored_enemies = []
	for enemy in enemies_in_cluster:
		var neighbor_count = 0
		for other in enemies_in_cluster:
			if enemy == other:
				continue
			if enemy.global_position.distance_to(other.global_position) < 80.0:
				neighbor_count += 1
		scored_enemies.append({"enemy": enemy, "score": neighbor_count})
	
	# Sort by score (most neighbors first)
	scored_enemies.sort_custom(func(a, b): return a.score > b.score)
	
	# Pick targets that are spread apart
	var min_spacing = 100.0
	var selected_targets: Array = []
	
	for item in scored_enemies:
		if selected_targets.size() >= count:
			break
		
		var enemy = item.enemy
		
		# Check if this enemy is far enough from already selected ones
		var too_close = false
		for selected in selected_targets:
			if enemy.global_position.distance_to(selected.global_position) < min_spacing:
				too_close = true
				break
		
		if not too_close:
			selected_targets.append(enemy)
	
	return selected_targets
	
func _on_level_up() -> void:
	explosions_per_use += 1
	explosion_spread += 10.0
	print("Explosion ability leveled up! Explosions: ", explosions_per_use, " Spread: ", explosion_spread)
