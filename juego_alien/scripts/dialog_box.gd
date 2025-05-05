extends Control

@onready var text_label = $Panel/RichTextLabel

func _ready():
	hide()

func show_dialog(text) -> void:
	text_label.text = text
	show()
