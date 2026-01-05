class_name HealthPickup
extends Area2D

@export var heal_amount: int = 20
@export var move_speed: float = 200.0
@export var pickup_range: float = 75.0

var player: Node2D = null
var is_moving_to_player: bool = false

func _ready() -> void:
	add_to_group("pickups")
	player = get_tree().get_first_node_in_group("player")
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play()
	
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var distance = global_position.distance_to(player.global_position)
	
	if distance < pickup_range:
		is_moving_to_player = true
	
	if is_moving_to_player:
		var direction = global_position.direction_to(player.global_position)
		global_position += direction * move_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_node("StatsManager"):
			body.stats.heal(heal_amount)
		queue_free()
