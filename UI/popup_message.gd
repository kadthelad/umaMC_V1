class_name PopupMessage
extends Control

@onready var title_label: Label = %TitleLabel
@onready var content_text_edit: TextEdit = %ContentTextEdit

func popup_window(title: String, content: String) -> void:
	title_label.text = title
	content_text_edit.text = content

func _on_close_button_pressed() -> void:
	queue_free()
