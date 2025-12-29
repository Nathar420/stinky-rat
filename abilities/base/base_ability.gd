class_name BaseAbility
extends Node2D

@export var ability_name: String = "Base Ability"
@export var base_cooldown: float = 1.0
@export var enabled: bool = false

var cooldown_timer: float = 0.0
var level: int = 0
var player: CharacterBody2D

func _ready() -> void:
	set_physics_process(false)

func initialize(player_node: CharacterBody2D) -> void:
	player = player_node
	_on_initialized()

# Override in child classes
func _on_initialized() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not enabled:
		return
	
	cooldown_timer -= delta
	if cooldown_timer <= 0:
		_execute_ability()
		cooldown_timer = base_cooldown

# Override this in child classes
func _execute_ability() -> void:
	pass

func unlock() -> void:
	enabled = true
	level = 1
	set_physics_process(true)
	_on_unlocked()

func level_up() -> void:
	level += 1
	_on_level_up()

# Override in child classes for unlock logic
func _on_unlocked() -> void:
	pass

# Override in child classes for level up effects
func _on_level_up() -> void:
	pass
