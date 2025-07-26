extends Control

@onready var panel = $CanvasLayer/Panel
@onready var dialog_text = $CanvasLayer/Panel/DialogBox/DialogText
@onready var dialog_speaker = $CanvasLayer/Panel/DialogBox/DialogSpeaker
@onready var dialog_options = $CanvasLayer/Panel/DialogBox/DialogOptions

#dialog_enabled and input_enabled vars are also updated in multiplayer_player.gd
func _ready():
	panel.visible = false

func show_dialog(speaker, text, options):
	panel.visible = true
	Global.player.dialog_enabled = true
	Global.player.input_enabled = false
	dialog_speaker.text = speaker
	dialog_text.text = text
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Remove existing options
	for option in dialog_options.get_children():
		dialog_options.remove_child(option)
	
	# Populate new options
	for option in options.keys():
		var button = Button.new()
		button.text = option
		button.add_theme_font_size_override("font_size", 20)
		button.pressed.connect(_on_option_selected.bind(option))
		dialog_options.add_child(button)
	
# Handle response selection
func _on_option_selected(option):
	get_parent().handle_dialog_choice(option)
	
func hide_dialog():
	panel.visible = false
	Global.player.input_enabled = true
	Global.player.dialog_enabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#al presionar ESC y no estar en diálogo, pues si estás en diálogo al presionar ESC la idea es cerrar el diálogo
