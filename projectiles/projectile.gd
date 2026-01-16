class_name Projectile
extends Area2D

@export var speed: float = 400.0
@export var damage: int = 10
@export var lifetime: float = 3.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	add_to_group("projectiles")
	rotation = direction.angle() + deg_to_rad(90)
	# Auto-destroy after lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_node("StatsManager"):
				var damage_result = player.stats.calculate_damage(damage)
				body.take_damage(damage_result.damage, damage_result.is_crit)
			else:
				body.take_damage(damage, false)
		queue_free()
