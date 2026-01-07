class_name SwordAbility
extends BaseAbility

@export var sword_scene: PackedScene
@export var swings_per_use: int = 1

var sword_instance: Sword = null
var facing_direction: Vector2 = Vector2.DOWN

func _on_initialized() -> void:
	ability_name = "Rusty Sword"
	base_cooldown = 1.5
	
	if sword_scene:
		sword_instance = sword_scene.instantiate()
		player.add_child(sword_instance)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if not enabled:
		return
	
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_direction.length() > 0:
		facing_direction = input_direction

func _execute_ability() -> void:
	_perform_sword_attacks()

func _perform_sword_attacks() -> void:
	if sword_instance == null:
		push_error("SwordAbility: No sword instance!")
		return
	
	for i in range(swings_per_use):
		if sword_instance and is_instance_valid(sword_instance):
			var swing_angle = facing_direction.angle()
			sword_instance.start_swing(swing_angle)
			
			await get_tree().create_timer(sword_instance.swing_duration).timeout

func _on_level_up() -> void:
	swings_per_use += 1
	print("Sword ability leveled up! Now swings ", swings_per_use, " times")
