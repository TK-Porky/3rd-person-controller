extends Resource
class_name ItemData

enum ItemType { WEAPON, KEY_ITEM, CONSUMABLE }

@export var item_name: String = ""
@export var item_type: ItemType = ItemType.KEY_ITEM
@export var description: String = ""
@export var icon: Texture2D = null

@export_category("Narrative")
@export var has_document: bool = false
@export var document_title: String = ""
@export_multiline var document_body: String = ""
@export var document_image: Texture2D = null
