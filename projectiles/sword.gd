class_name Sword
extends Node2D

@export var damage: int = 30
@export var swing_duration: float = 0.3
@export var swing_arc: float = 120.0

var is_swinging: bool = false
var hit_enemies: Array = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Area2D

func _ready() -> void:
	if hitbox:
		hitbox.body_entered.connect(_on_body_entered)
	visible = false

func start_swing(direction_angle: float) -> void:
	if is_swinging:
		return
	
	is_swinging = true
	hit_enemies.clear()
	visible = true
	
	var start_angle = direction_angle - deg_to_rad(swing_arc / 2)
	var end_angle = direction_angle + deg_to_rad(swing_arc / 2)
	
	rotation = start_angle
	
	var tween = create_tween()
	tween.tween_property(self, "rotation", end_angle, swing_duration)
	
	await tween.finished
	
	is_swinging = false
	visible = false

func _on_body_entered(body: Node2D) -> void:
	if not is_swinging:
		return
	
	if body.is_in_group("enemies") and body not in hit_enemies:
		if body.has_method("take_damage"):
			body.take_damage(damage)
			hit_enemies.append(body)


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
