extends CharacterBody3D

@onready var camera = $Camera3D


@export var jump_velocity = 4.5

var look_sensitivity = ProjectSettings.get_setting("player/look_sensitivity")
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var SPEED = 10
@export var input_enabled:bool = true
@export var dialog_enabled:bool = false
var lastTarget = null

func _ready():
	name = str(get_multiplayer_authority())
	$Name.text = str(name)
	if is_multiplayer_authority():
		Global.player = self        #para tener la variable player globalmente
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera.current = true        #se le pone la cámara correspondiente al jugador que tenga la autoridad
	while true:
		await get_tree().create_timer(2.0).timeout
		print("dialog_enabled: ", dialog_enabled)
		print("input_enabled: ", input_enabled)

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

#var dialog_box = get_tree().get_current_scene().get_node_or_null("CanvasLayer/DialogBox")
#if dialog_box:
	#pass
	##print("Node found!")
#else:
	#print("Node Game/CanvasLayer/DialogBox not found on scripts/player/ray_cast_3d.gd")
	#
#dialog_box.show_dialog("hola q tal") #texto que se pondrá en el diálogo

func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event.is_action_pressed("ui_cancel"):
		if dialog_enabled:
			#print("caso diálogo")
			lastTarget.get_node("DialogManager").hide_dialog()
		else:
			#print("caso normal")
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				input_enabled = true
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				input_enabled = false

	if not input_enabled: return
	if event is InputEventMouseMotion :
		global_rotation.y += -event.relative.x * look_sensitivity
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
		remote_set_rotation.rpc(global_rotation)
		
	#para interacciones
	if event.is_action_pressed("Interact"):
		var target = $Camera3D/RayCast3D.get_collider()
		if target != null:
			if target.is_in_group("NPC"):
				print("hablando con el NPC")
				#input_enabled = false
				#dialog_enabled = true
				target.start_dialog()
				lastTarget = target
			if target.is_in_group("Item"):
				print("interactuando con item")
				target.start_interact()

@rpc("unreliable", "call_remote")
func remote_set_position(authority_position):
	global_position = authority_position

@rpc ("unreliable", "call_remote")
func remote_set_rotation(authority_rotation):
	rotation = authority_rotation
