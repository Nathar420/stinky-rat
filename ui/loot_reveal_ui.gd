class_name LootRevealUI
extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var item_name_label: Label = $Panel/MarginContainer/VBoxContainer/ItemNameLabel
@onready var item_description_label: Label = $Panel/MarginContainer/VBoxContainer/ItemDescriptionLabel
@onready var claim_button: Button = $Panel/MarginContainer/VBoxContainer/ClaimButton

var current_item: ItemData
var current_player: Node2D

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	if claim_button:
		claim_button.pressed.connect(_on_claim_pressed)

func show_loot(item: ItemData, player_node: Node2D) -> void:
	current_item = item
	current_player = player_node
	
	if item_name_label:
		item_name_label.text = item.display_name
	
	if item_description_label:
		item_description_label.text = item.description
	
	show()
	get_tree().paused = true

func _on_claim_pressed() -> void:
	if current_player and current_item:
		if current_player.has_method("_on_upgrade_chosen"):
			current_player._on_upgrade_chosen(current_item)
	
	hide()
	get_tree().paused = false
