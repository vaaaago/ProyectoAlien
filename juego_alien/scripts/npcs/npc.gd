extends CharacterBody3D

@export var npc_id: String   #al crear un NPC le ponemos id y name
@export var npc_name: String

@onready var dialog_manager = $DialogManager
@export var dialog_resource: Dialog

#Dialog variables
var current_state = "start"
var current_branch_index = 0

func _ready():
	#load_dialog data
	dialog_resource.load_from_json("res://resources/dialog/dialog_data.json")
	#initialize npc reference to fetch the correct data
	dialog_manager.npc = self

func start_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if npc_dialogs.is_empty():
		return
	dialog_manager.show_dialog(self)

#get the current branch dialog
func get_current_dialog():
	var npc_dialogs = dialog_resource.get_npc_dialog(npc_id)
	if current_branch_index < npc_dialogs.size():
		for dialog in npc_dialogs[current_branch_index]["dialogs"]:
			if dialog["state"] == current_state:
				return dialog
	return null
	
#Update dialog branch
func set_dialog_tree(branch_index):
	current_branch_index = branch_index
	current_state = "start"

#Update dialog state
func set_dialog_state(state):
	current_state = state
