class_name FloatingScore
extends Node2D

@export var float_speed: float = 50.0
@export var lifetime: float = 1.0

@onready var label: Label = $Label

func _ready() -> void:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 50, lifetime)
	tween.tween_property(label, "modulate:a", 0.0, lifetime)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func set_score(value: int) -> void:
	if label:
		label.text = "+" + str(value)
