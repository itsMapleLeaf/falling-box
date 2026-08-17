extends Control

const MAX_LOG_COUNT := 100

var logs: Array[String]
var debug_values: Dictionary[String, Variant] = { }

@onready var log_message_list: VBoxContainer = %LogMessageList
@onready var log_message_placeholder: InstancePlaceholder = %LogMessage
@onready var log_scroll_container: ScrollContainer = %LogScrollContainer
@onready var debug_value_label: Label = %DebugValues


func set_debug_value(value_name: String, value: Variant) -> void:
	debug_values[value_name] = value

	debug_value_label.text = ""
	for key in debug_values:
		debug_value_label.text += "%s: %s\n" % [key, str(debug_values[key])]


func log(msg: Variant) -> void:
	var message_node := log_message_placeholder.create_instance()
	message_node.text = str(msg)

	log_scroll_container.get_v_scroll_bar().value = 1

	if log_message_list.get_child_count() > MAX_LOG_COUNT:
		log_message_list.get_child(0).queue_free()
