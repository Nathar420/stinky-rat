class_name ItemData
extends Resource

enum ItemType {
	WEAPON,
	PASSIVE,
	CONSUMABLE
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.WEAPON
@export var max_level: int = 10
