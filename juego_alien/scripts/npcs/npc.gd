extends CharacterBody3D

@export var npc_id: String   #al crear un NPC le ponemos id y name
@export var npc_name: String

func start_dialog():
	print("Hello player!")
