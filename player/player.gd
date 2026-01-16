class_name Player
extends CharacterBody2D

@export var base_speed: float = 250.0

@onready var stats: StatsManager = $StatsManager
@onready var ability_manager: AbilityManager = $AbilityManager

@onready var animation: AnimatedSprite2D = $rat_animation



var is_invulnerable: bool = false
var knockback_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("player")
	# Create unique material copy for player
	if animation.material:
		animation.material = animation.material.duplicate()
	
	ability_manager.initialize(self)
	stats.stat_changed.connect(_on_stat_changed)
	stats.level_up.connect(_on_level_up)
	ability_manager.initialize(self)
	stats.stat_changed.connect(_on_stat_changed)
	stats.level_up.connect(_on_level_up)
	
	var basic_gun = $AbilityManager/BasicGun
	ability_manager.register_ability("basic_gun", basic_gun)
	ability_manager.unlock_ability("basic_gun")
	
	var ricochet_gun = $AbilityManager/RicochetGun
	ability_manager.register_ability("ricochet", ricochet_gun)
	
	var explosion_ability = $AbilityManager/ExplosionAbility
	ability_manager.register_ability("explosion", explosion_ability)
	
	var confusion_spoon = $AbilityManager/ConfusionSpoon
	ability_manager.register_ability("spoon", confusion_spoon)
	
	var sword_ability = $AbilityManager/SwordAbility
	ability_manager.register_ability("sword", sword_ability)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _handle_movement(_delta: float) -> void:
	# Apply knockback if active
	if knockback_velocity.length() > 5.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.15)
		
		# Still play animations during knockback
		if knockback_velocity.x > 0:
			animation.flip_h = false
			animation.play("walk_right")
		elif knockback_velocity.x < 0:
			animation.flip_h = true
			animation.play("walk_left")
		
		move_and_slide()
		return  # Skip normal movement
	
	# Normal movement
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * base_speed * stats.movement_speed_multiplier
	
	# Handle animations
	if direction.length() > 0:
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				animation.flip_h = false
				animation.play("walk_right")
			else:
				animation.flip_h = true
				animation.play("walk_left")
		else:
			if direction.y > 0:
				animation.play("walk_down")
			else:
				animation.play("walk_up")
	else:
		animation.play("idle")
	
	move_and_slide()

func take_damage(amount: int, from_position: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable:
		return
	
	stats.take_damage(amount)
	
	if stats.current_health <= 0:
		_die()
		return
	
	# KNOCKBACK
	if from_position != Vector2.ZERO:
		var knockback_direction = (global_position - from_position).normalized()
		knockback_velocity = knockback_direction * 400.0  # Increased strength
		print("Player knocked back! Direction: ", knockback_direction, " Velocity: ", knockback_velocity)
	
	_start_invulnerability()
	_flash_damage()
	
	# Screen shake
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("add_shake"):
		camera.add_shake(3.0)
		
func _flash_damage() -> void:
	# Get the sprite's material
	var sprite_material = animation.material as ShaderMaterial
	if not sprite_material:
		return
	
	# Flash white
	sprite_material.set_shader_parameter("flash_amount", 1.0)
	
	# Fade back to normal
	var tween = create_tween()
	tween.tween_method(
		func(value): sprite_material.set_shader_parameter("flash_amount", value),
		1.0,
		0.0,
		0.2
	)

func _start_invulnerability() -> void:
	is_invulnerable = true
	
	await get_tree().create_timer(1.0).timeout
	
	is_invulnerable = false

func _die() -> void:
	print("Player died!")
	
	var game_over_ui = get_tree().get_first_node_in_group("game_over_ui")
	
	if game_over_ui:
		var survival_time = 0.0
		
		var world = get_tree().current_scene
		if world and world.has_node("GameUI"):
			var game_ui = world.get_node("GameUI")
			survival_time = game_ui.game_time
		
		game_over_ui.show_game_over(stats, survival_time)
	else:
		push_error("Game Over UI not found!")

func _on_stat_changed(stat_name: String, _old_value, new_value) -> void:
	print("Stat changed: ", stat_name, " = ", new_value)

func _on_level_up(new_level: int) -> void:
	print("Level up! Now level ", new_level)
	
	var level_up_ui = get_tree().get_first_node_in_group("level_up_ui")
	print("level_up_ui exists: ", level_up_ui != null)
	
	if level_up_ui:
		print("Calling show_upgrades...")
		level_up_ui.show_upgrades(stats)
		level_up_ui.upgrade_chosen.connect(_on_upgrade_chosen)
	else:
		print("ERROR: level_up_ui not found in group!")
		
func _on_upgrade_chosen(item: ItemData) -> void:
	print("Chose upgrade: ", item.display_name)
	
	stats.weapon_levels[item.id] = stats.weapon_levels.get(item.id, 0) + 1
	
	match item.id:
		"basic_gun":
			if ability_manager.has_ability("basic_gun"):
				ability_manager.level_up_ability("basic_gun")
			else:
				# Already unlocked at start, just level it up
				ability_manager.level_up_ability("basic_gun")
		"projectile_count":
			stats.increase_projectile_count(1)
		"speed_boost":
			stats.increase_movement_speed(0.25)
		"max_health":
			stats.increase_max_health(20)
		"damage_boost":
			stats.increase_damage(0.2)
		"cooldown_reduction":
			stats.reduce_cooldown(0.1)
		"pickup_range":
			stats.increase_pickup_range(0.3)
		"projectile_speed":
			stats.increase_projectile_speed(0.15)
		"area_size":
			stats.increase_area_size(0.15)
		"armor":
			stats.add_armor(0.1)
		"ricochet":
			if ability_manager.has_ability("ricochet"):
				ability_manager.level_up_ability("ricochet")
			else:
				ability_manager.unlock_ability("ricochet")
		"explosion":
			if ability_manager.has_ability("explosion"):
				ability_manager.level_up_ability("explosion")
			else:
				ability_manager.unlock_ability("explosion")
		"spoon":
			if ability_manager.has_ability("spoon"):
				ability_manager.level_up_ability("spoon")
			else:
				ability_manager.unlock_ability("spoon")
		"sword":
			if ability_manager.has_ability("sword"):
				ability_manager.level_up_ability("sword")
			else:
				ability_manager.unlock_ability("sword")
		"crit_chance":
			stats.increase_crit_chance(0.10)
		"crit_damage":
			stats.increase_crit_multiplier(0.25)
