@tool
extends Area3D

@onready var mesh_holder = $Mesh

# vars
@export var item_id: String = ""
@export var item_quantity: int = 1
@export var item_mesh: PackedScene
#
func _ready():
	# show texture in game
	if not Engine.is_editor_hint() and item_mesh:
		var instance = item_mesh.instantiate()

		# Try to find the MeshInstance3D node inside the instanced scene
		var mesh_node = find_mesh_instance(instance)

		if mesh_node and mesh_node is MeshInstance3D:
			mesh_holder.mesh = mesh_node.mesh
		else:
			print(" Could not find MeshInstance3D in the scene.")

func find_mesh_instance(root: Node) -> MeshInstance3D:
	for child in root.get_children():
		if child is MeshInstance3D:
			return child
		elif child.get_child_count() > 0:
			var result = find_mesh_instance(child)
			if result:
				return result
	return null
