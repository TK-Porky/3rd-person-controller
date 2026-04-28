extends CanvasLayer
class_name DocumentScreen

signal choice_made(choice: String)

@onready var panel: PanelContainer       = $Panel
@onready var doc_image: TextureRect      = %DocumentImage
@onready var doc_title: RichTextLabel    = %Title
@onready var doc_body: RichTextLabel     = %Body

@onready var p_document_title: RichTextLabel = $DocumentImage/MarginContainer/VBoxContainer/PDocumentTitle
@onready var p_document_body: RichTextLabel = $DocumentImage/MarginContainer/VBoxContainer/PDocumentBody

func _ready() -> void:
	visible = false

func show_document(item: ItemData) -> void:
	if item.document_image:
		doc_image.texture = item.document_image
		p_document_title.text = item.document_title
		p_document_body.text = item.document_body
	doc_title.text = "[b]%s[/b]" % item.document_title
	doc_body.text  = item.document_body

	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		take()

func take() -> void:
	_close("take")

func destroy() -> void:
	_close("destroy")

func _close(choice: String) -> void:
	visible = false
	get_tree().paused = false
	choice_made.emit(choice)
