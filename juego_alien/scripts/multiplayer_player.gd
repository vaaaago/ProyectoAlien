extends CharacterBody3D

@onready var camera = $Camera3D


@export var jump_velocity = 4.5

var look_sensitivity = ProjectSettings.get_setting("player/look_sensitivity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var SPEED = 10
var input_enabled := true

func _ready():
	name = str(get_multiplayer_authority())
	$Name.text = str(name)
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true        #se le pone la cámara correspondiente al jugador que tenga la autoridad
	
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward","move_backward")
	#print(input_dir)
	if not input_enabled:
		input_dir = Vector2.ZERO
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if is_on_floor():
		velocity.y = 0
		if Input.is_action_just_pressed("jump") and input_enabled: velocity.y = jump_velocity
	else:
		velocity.y -= gravity * delta
	remote_set_position.rpc(global_position) #envía la velocidad del jugador
	move_and_slide()
	
	if Input.is_action_just_pressed("ui_cancel"): #al presionar ESC+
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			input_enabled = true
		else: 
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			input_enabled = false
	
		
func _unhandled_input(event):
	if not is_multiplayer_authority() or not input_enabled: return
	
	if event is InputEventMouseMotion :
		global_rotation.y += -event.relative.x * look_sensitivity
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		remote_set_rotation.rpc(global_rotation)		
	
@rpc("unreliable", "call_remote")
func remote_set_position(authority_position):
	global_position = authority_position

@rpc ("unreliable", "call_remote")
func remote_set_rotation(authority_rotation):
	rotation = authority_rotation
