extends CharacterBody3D

func _ready():
	name = str(get_multiplayer_authority())
	$Name.text = str(name)
	
func _physics_process(delta):
	if is_multiplayer_authority():
		var direction:Vector3 = Vector3.ZERO
		
		if Input.is_key_pressed(KEY_W): direction.z -=1
		if Input.is_key_pressed(KEY_S): direction.z +=1
		if Input.is_key_pressed(KEY_A): direction.x -=1
		if Input.is_key_pressed(KEY_D): direction.x +=1
		
		global_position += direction.normalized()
		remote_set_position.rpc(global_position) #envía la posición del jugador
	
@rpc("unreliable")
func remote_set_position(authority_position):
	global_position = authority_position
