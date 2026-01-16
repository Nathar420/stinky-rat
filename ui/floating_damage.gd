class_name FloatingDamage
extends Node2D

@export var float_speed: float = 30.0
@export var lifetime: float = 0.6

var is_crit: bool = false
var shake_amount: float = 0.0
var shake_time: float = 0.0

func _ready() -> void:
	var label = get_node_or_null("Label")
	if not label:
		push_error("FloatingDamage: Label node not found!")
		queue_free()
		return
	
	# Start shake timer for crits
	if is_crit:
		shake_time = 0.5 # Shake for 0.3 seconds
		shake_amount = 4.0  # Shake intensity
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 40, lifetime)
	tween.tween_property(label, "modulate:a", 0.0, lifetime)
	
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	if shake_time > 0:
		shake_time -= delta
		
		var label = get_node_or_null("Label")
		if label:
			# Random shake offset
			var shake_offset = Vector2(
				randf_range(-shake_amount, shake_amount),
				randf_range(-shake_amount, shake_amount)
			)
			label.position = shake_offset
			
			# Decay shake over time
			shake_amount = lerp(shake_amount, 0.0, delta * 5.0)
	else:
		# Reset label position when shake is done
		var label = get_node_or_null("Label")
		if label:
			label.position = Vector2.ZERO

func set_damage(value: int, is_crit_hit: bool = false) -> void:
	var label = get_node_or_null("Label")
	if not label:
		push_error("FloatingDamage: Can't find Label!")
		return
	
	is_crit = is_crit_hit
	
	if is_crit:
		label.text = str(value)
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0, 1.0))  # Gold color
		label.scale = Vector2(1.3, 1.3)
		
		# Add outline for extra pop
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color(0.5, 0.0, 0.0, 1.0))  # Dark red outline
	else:
		label.text = str(value)
		label.add_theme_font_size_override("font_size", 16)
		label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))  # White
