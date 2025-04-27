extends MultiplayerSynchronizer

var input_direction : Vector2

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "move_left"
## Name of Input Action to move Right.
@export var input_right : String = "move_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "move_up"
## Name of Input Action to move Backward.
@export var input_back : String = "move_down"
## Name of Input Action to Jump.
@export var input_jump : String = "jump"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"

func _ready() -> void:
	
	if get_multiplayer_authority() != multiplayer.get_unique_id(): #si hay algo externo que esté aplicando físicas a un cliente, quitarle permisos para mover
		set_process(false)
		set_physics_process(false)
	
	input_direction = Input.get_vector(input_left, input_right, input_forward, input_back)
	
func _physics_process(delta: float) -> void:
	
	input_direction = Input.get_vector(input_left, input_right, input_forward, input_back)
	
func _process(delta):
	pass
