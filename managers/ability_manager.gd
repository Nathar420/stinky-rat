class_name AbilityManager
extends Node

var abilities: Dictionary = {}  # Key: ability_id, Value: BaseAbility instance
var player: CharacterBody2D

func initialize(player_node: CharacterBody2D) -> void:
	player = player_node

func register_ability(ability_id: String, ability: BaseAbility) -> void:
	abilities[ability_id] = ability
	add_child(ability)
	ability.initialize(player)

func unlock_ability(ability_id: String) -> void:
	if ability_id in abilities:
		abilities[ability_id].unlock()
		print("Unlocked ability: ", ability_id)
	else:
		push_error("Ability not registered: " + ability_id)

func level_up_ability(ability_id: String) -> void:
	if ability_id in abilities:
		abilities[ability_id].level_up()
		print("Leveled up ability: ", ability_id, " to level ", abilities[ability_id].level)
	else:
		push_error("Ability not registered: " + ability_id)

func has_ability(ability_id: String) -> bool:
	return ability_id in abilities and abilities[ability_id].enabled

func get_ability(ability_id: String) -> BaseAbility:
	return abilities.get(ability_id)

func get_ability_level(ability_id: String) -> int:
	if ability_id in abilities:
		return abilities[ability_id].level
	return 0
