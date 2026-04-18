extends PanelContainer
class_name DebugPanel

var _entries: Dictionary = {}

@onready var _container: VBoxContainer = $MarginContainer/Container

const LABEL_STYLE := "[color=gray]%s[/color] [color=white]%s[/color]"

func _ready() -> void:
	set_process(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		visible = not visible

func _process(_delta: float) -> void:
	if not visible: return
	_refresh()

# Register an entry.
# Example: debug_panel.register("velocity", func(): return player.velocity)
func register(key: String, value_getter: Callable) -> void:
	_entries[key] = value_getter
	var label := RichTextLabel.new()
	label.name = key
	label.bbcode_enabled = true
	label.fit_content = true
	_container.add_child(label)

func unregister(key: String) -> void:
	_entries.erase(key)
	var node := _container.get_node_or_null(key)
	if node: node.queue_free()

func _refresh() -> void:
	for key in _entries:
		var label := _container.get_node_or_null(key)
		if not label: continue
		var value =_entries[key].call()
		label.text = LABEL_STYLE % [key, _format(value)]
	
func _format(value) -> String:
	if value is Vector3:
		return "(%.2f, %.2f, %.2f)" % [value.x, value.y, value.z]
	if value is float:
		return "%.3f" % value
	if value is bool:
		return "[color=%s]%s[/color]" % ["green" if value else "red", value]
	return str(value)
