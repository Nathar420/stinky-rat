class_name ConfusionBurst
extends Area2D

@export var burst_radius: float = 150.0
@export var confusion_duration: float = 5.0

func _ready() -> void:
	add_to_group("confusion_bursts")
	
	if has_node("CollisionShape2D"):
		var shape = $CollisionShape2D.shape as CircleShape2D
		if shape:
			shape.radius = burst_radius
	
	_confuse_enemies()
	_play_visual_effect()

func _confuse_enemies() -> void:
	await get_tree().process_frame
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var confused_count = 0
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		
		var distance = global_position.distance_to(enemy.global_position)
		if distance <= burst_radius:
			if enemy.has_method("confuse"):
				enemy.confuse(confusion_duration)
				confused_count += 1
	
	print("Confusion burst affected ", confused_count, " enemies")

func _play_visual_effect() -> void:
	var sprite = null
	
	if has_node("Sprite2D"):
		sprite = $Sprite2D
	elif has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
	
	if sprite:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2(4, 4), 0.5).from(Vector2(0.5, 0.5))
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5).from(1.0)
		
		await tween.finished
	else:
		await get_tree().create_timer(0.5).timeout
	
	queue_free()
