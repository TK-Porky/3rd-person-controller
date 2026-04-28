extends Interactable
class_name DocumentInteractable

@export var item_data: ItemData

func _ready() -> void:
	super._ready()

func _on_interact() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player: return

	var doc_screen: DocumentScreen = player.hud.get_document_screen()
	doc_screen.choice_made.connect(_on_choice_made, CONNECT_ONE_SHOT)
	doc_screen.show_document(item_data)

func _on_choice_made(choice: String) -> void:
	match choice:
		"take":
			_on_take()
		"destroy":
			_on_destroy()

func _on_take() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player: return
	player.hud.show_notification("Dossier récupéré. Rejoignez la sortie.")
	queue_free()

func _on_destroy() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player: return
	player.hud.show_notification("Dossier détruit. Objectif modifié.")
	queue_free()
