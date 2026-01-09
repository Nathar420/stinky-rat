class_name LootChest
extends Area2D

static var chests_opened: int = 0

@export var base_cost: int = 10
@export var cost_increase: int = 5

@onready var cost_label: Label = $CostLabel

var player: Node2D = null

func _ready() -> void:
	add_to_group("loot_chests")
	player = get_tree().get_first_node_in_group("player")
	body_entered.connect(_on_body_entered)
	
	if cost_label:
		cost_label.text = str(get_chest_cost())

func get_chest_cost() -> int:
	return base_cost + (chests_opened * cost_increase)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	if not body.has_node("StatsManager"):
		return
	
	var stats = body.stats
	var cost = get_chest_cost()
	
	if stats.current_gold >= cost:
		stats.add_gold(-cost)
		chests_opened += 1
		
		_open_chest(body)
	else:
		_flash_insufficient_gold()

func _open_chest(player_node: Node2D) -> void:
	var item_db = get_tree().get_first_node_in_group("item_database")
	if not item_db:
		push_error("ItemDatabase not found!")
		queue_free()
		return
	
	var item = item_db.get_random_chest_item(player_node.stats)
	
	if item:
		var loot_ui = get_tree().get_first_node_in_group("loot_reveal_ui")
		if loot_ui:
			loot_ui.show_loot(item, player_node)
		else:
			# Fallback: apply item directly
			_apply_item_to_player(item, player_node)
	
	queue_free()

func _apply_item_to_player(item: ItemData, player_node: Node2D) -> void:
	if player_node.has_method("_on_upgrade_chosen"):
		player_node._on_upgrade_chosen(item)

func _flash_insufficient_gold() -> void:
	if not cost_label:
		return
	
	var original_color = cost_label.get_theme_color("font_color", "Label")
	cost_label.add_theme_color_override("font_color", Color.RED)
	
	await get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(cost_label):
		cost_label.add_theme_color_override("font_color", original_color)
