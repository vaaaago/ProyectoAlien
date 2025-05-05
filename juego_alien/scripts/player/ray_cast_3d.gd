extends RayCast3D

func _process(delta):
	if is_colliding():
		if Input.is_action_just_released("Interact"):
			print("interacting!!")
			var dialog_box = get_tree().get_current_scene().get_node_or_null("CanvasLayer/DialogBox")
			if dialog_box:
				pass
				#print("Node found!")
			else:
				print("Node Game/CanvasLayer/DialogBox not found on scripts/player/ray_cast_3d.gd")
				
			dialog_box.show_dialog("hola q tal") #texto que se pondrá en el diálogo
		
