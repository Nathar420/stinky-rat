class_name Player
extends CharacterBody2D

@export var base_speed: float = 250.0

@onready var stats: StatsManager = $StatsManager
@onready var ability_manager: AbilityManager = $AbilityManager

@onready var animation: AnimatedSprite2D = $rat_animation



var is_invulnerable: bool = false

func _ready() -> void:
	add_to_group("player")
	
	# Initialize managers
	ability_manager.initialize(self)
	stats.stat_changed.connect(_on_stat_changed)
	stats.level_up.connect(_on_level_up)
	
	# Register and unlock basic gun
	var basic_gun = $AbilityManager/BasicGun
	ability_manager.register_ability("basic_gun", basic_gun)
	ability_manager.unlock_ability("basic_gun")
	# Register ricochet (but don't unlock yet)
	var ricochet_gun = $AbilityManager/RicochetGun
	ability_manager.register_ability("ricochet", ricochet_gun)
	# Connect to stats signals
	stats.stat_changed.connect(_on_stat_changed)
	stats.level_up.connect(_on_level_up)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)

func _handle_movement(_delta: float) -> void:
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
		animation.play("idle")  # or animation.stop() if you don't have idle
	
	move_and_slide()

func take_damage(amount: int) -> void:
	if is_invulnerable:
		return
	
	stats.take_damage(amount)
	
	if stats.current_health <= 0:
		_die()
		return
	
	_start_invulnerability()

func _start_invulnerability() -> void:
	is_invulnerable = true
	modulate = Color(1, 0.5, 0.5)
	
	await get_tree().create_timer(1.0).timeout
	
	is_invulnerable = false
	modulate = Color.WHITE

func _die() -> void:
	print("Player died!")
	queue_free()
	# TODO: Add death screen/restart logic

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
		"speed_boost":
			stats.increase_movement_speed(0.25)
		"max_health":
			stats.increase_max_health(20)
		"ricochet":
			if ability_manager.has_ability("ricochet"):
				ability_manager.level_up_ability("ricochet")
			else:
				ability_manager.unlock_ability("ricochet")
		"explosion", "sword", "spoon":
			print("Weapon upgrade: ", item.id, " - needs ability implementation")
