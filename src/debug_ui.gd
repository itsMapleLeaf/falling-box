extends CanvasLayer

@onready var label: Label = $Label

var debug_values: Dictionary[String, Variant] = { }


func set_debug_value(name: String, value: Variant) -> void:
	debug_values[name] = value


func _process(delta: float) -> void:
	label.text = ""
	for key in debug_values:
		label.text += "%s: %s\n" % [key, str(debug_values[key])]
