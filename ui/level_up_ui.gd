class_name LevelUpUI
extends CanvasLayer

signal upgrade_chosen(item: ItemData)

@onready var panel: Panel = $Panel
@onready var title_label: Label = $Panel/MarginContainer/VBoxContainer/TitleLabel
@onready var button_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ButtonContainer

@export var upgrade_button_scene: PackedScene

var item_database: ItemDatabase
var stats_manager: StatsManager

func _ready() -> void:
	hide()
	
	item_database = get_tree().get_first_node_in_group("item_database")
	if item_database == null:
		push_error("LevelUpUI: ItemDatabase not found!")

func show_upgrades(stats: StatsManager) -> void:
	print("show_upgrades called!")
	stats_manager = stats
	
	_clear_buttons()
	print("Buttons cleared")
	
	var upgrades = item_database.get_random_upgrades(3, stats)
	print("Got ", upgrades.size(), " upgrades")
	
	if upgrades.is_empty():
		push_warning("No upgrades available!")
		return
	
	for upgrade in upgrades:
		print("Creating button for: ", upgrade.display_name)
		_create_upgrade_button(upgrade)
	print("Showing UI and pausing...")
	show()
	get_tree().paused = true

func _clear_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()

func _create_upgrade_button(item: ItemData) -> void:
	print("_create_upgrade_button called for: ", item.display_name)
	var button: UpgradeButton
	
	if upgrade_button_scene:
		print("Instantiating from scene")
		button = upgrade_button_scene.instantiate()
	else:
		print("Creating new UpgradeButton")
		button = UpgradeButton.new()
	
	button_container.add_child(button)
	print("Button added to container")
	
	var current_level = stats_manager.weapon_levels.get(item.id, 0)
	button.setup(item, current_level)
	print("Button setup complete")
	button.upgrade_selected.connect(_on_upgrade_selected)
	print("Signal connected")

func _on_upgrade_selected(item: ItemData) -> void:
	print("LevelUpUI: Upgrade selected - ", item.display_name)
	hide()
	get_tree().paused = false
	upgrade_chosen.emit(item)
