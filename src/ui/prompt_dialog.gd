@tool
class_name PromptDialog
extends CanvasLayer


class Submission:
	var answer := ""
	var cancelled := false


signal submitted(result: Submission)

@export var prefilled_answer: String = ""

@export var query: String = "":
	set(value):
		query = value
		if is_node_ready():
			query_label.text = value

@export var placeholder: String = "":
	set(value):
		placeholder = value
		if is_node_ready():
			answer_input.placeholder_text = value

@export var submit_text: String = "Submit":
	set(value):
		submit_text = value
		if is_node_ready():
			submit_button.text = value

@export var cancel_text: String = "Cancel":
	set(value):
		cancel_text = value
		if is_node_ready():
			cancel_button.text = value

var answer: String

@onready var query_label: Label = %QueryLabel
@onready var answer_input: LineEdit = %AnswerInput
@onready var submit_button: Button = %SubmitButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	query_label.text = query
	answer_input.text = prefilled_answer
	answer_input.placeholder_text = placeholder
	submit_button.text = submit_text

	if not Engine.is_editor_hint():
		hide()


func ask() -> Submission:
	show()
	var result: Submission = await submitted
	hide()
	return result


func set_answer(new_answer: String) -> void:
	answer = new_answer
	answer_input.text = new_answer


func submit() -> void:
	if not visible:
		return

	var result := Submission.new()
	result.answer = answer.strip_edges()
	submitted.emit(result)


func _on_answer_input_text_changed(new_text: String) -> void:
	answer = new_text


func _on_submit_button_pressed() -> void:
	submit()


func _on_cancel_button_pressed() -> void:
	var result := Submission.new()
	result.cancelled = true
	submitted.emit(result)


func _on_visibility_changed() -> void:
	if visible:
		answer_input.grab_focus()


func _on_answer_input_text_submitted(_new_text: String) -> void:
	submit()
