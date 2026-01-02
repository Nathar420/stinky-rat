extends CharacterBody2D

@export var health: int = 30
@export var move_speed: float = 50.0

var player: Node2D

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta: float) -> void:
	if player == null:
		return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy took ", amount, " damage. Health: ", health)
	
	# Flash white
	modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1, 1)
	
	if health <= 0:
		_die()

func _die() -> void:
	print("Enemy died!")
	queue_free()
