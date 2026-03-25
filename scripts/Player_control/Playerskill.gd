extends MultiMeshInstance3D
#region config
@export_subgroup("setting")
@export var spacing = 3.0
@export var spawn_distance: float = 5.0

var target_enemy: Node3D = null;
var Armature: Node3D;
var total_instances: int;
var Board_Created: bool = false;
#endregion

func _ready() -> void:
	Armature = get_node("../Armature")
	if (Armature == null):
		print_debug("shit")
	pass

#region Input handler
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("Q"):
			if not Board_Created:
				Board_Created = true
				create_board(8)
			else:
				Board_Created = false
				Destroy_Board()
#endregion

func create_board(board_size: int) -> void:
	total_instances = board_size * board_size
	
	multimesh.instance_count = total_instances
	var spawn_pos = Armature.global_position - (Armature.global_transform.basis.z * spawn_distance)
	
	var offset = (board_size - 1) * spacing / 2.0
	for i in range(total_instances):
		var x = i % board_size
		var z = i / board_size
		
		# Local grid position relative to the calculated spawn_pos
		var local_pos = Vector3(x * spacing - offset, 0, z * spacing - offset)
		var final_pos = spawn_pos + local_pos
		
		# Apply transform (Keeping identity basis/rotation)
		var xform = Transform3D(Basis(), final_pos)
		multimesh.set_instance_transform(i, xform)
		
		# Chessboard coloring
		var color = Color.WHITE if (x + z) % 2 == 0 else Color.BLACK
		multimesh.set_instance_color(i, color)

func Destroy_Board() -> void:
	for i in range(total_instances):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)));
	pass
func _process(delta: float) -> void:
	pass
