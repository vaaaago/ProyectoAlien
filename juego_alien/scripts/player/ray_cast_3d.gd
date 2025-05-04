extends RayCast3D

func _process(delta):
	if is_colliding():
		if Input.is_action_just_released("Interact"):
			print("interaction!!!")
		
