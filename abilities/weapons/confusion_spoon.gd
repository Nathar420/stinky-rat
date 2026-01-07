class_name ConfusionSpoon
extends BaseAbility

@export var burst_scene: PackedScene
@export var burst_radius: float = 150.0
@export var confusion_duration: float = 5.0

func _on_initialized() -> void:
	ability_name = "Confusion Spoon"
	base_cooldown = 7.0

func _execute_ability() -> void:
	_fire_confusion_burst()

func _fire_confusion_burst() -> void:
	if burst_scene == null:
		push_error("ConfusionSpoon: No burst scene assigned!")
		return
	
	var burst = burst_scene.instantiate()
	burst.global_position = player.global_position
	burst.burst_radius = burst_radius
	burst.confusion_duration = confusion_duration
	
	player.get_parent().add_child(burst)
	
	print("Confusion Spoon activated! Radius: ", burst_radius, " Duration: ", confusion_duration)

func _on_level_up() -> void:
	burst_radius += 25.0
	confusion_duration += 1.0
	print("Confusion Spoon leveled up! Radius: ", burst_radius, " Duration: ", confusion_duration, "s")
