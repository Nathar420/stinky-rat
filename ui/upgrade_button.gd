class_name UpgradeButton
extends Button

signal upgrade_selected(item: ItemData)

var item_data: ItemData

func _ready() -> void:
	pressed.connect(_on_pressed)

func setup(item: ItemData, current_level: int) -> void:
	item_data = item
	
	var level_text = ""
	if current_level == 0:
		level_text = "[NEW]"
	else:
		level_text = "[Level %d → %d]" % [current_level, current_level + 1]
	
	text = "%s %s\n%s" % [item.display_name, level_text, item.description]

func _on_pressed() -> void:
	print("Button pressed! Item: ", item_data.display_name if item_data else "null")
	if item_data:
		upgrade_selected.emit(item_data)
