extends MultiMeshInstance3D

#region -----variables-----
@export_subgroup("setting")
@export var spacing: float = 2.0
@export var spawn_distance: float = 5.0
@export var lower_value: float = 10.0

var target_enemy: Node3D = null
var armature: Node3D
var total_instances: int
var board_created: bool = false
var angle: float
#endregion

func _ready() -> void:
	armature = get_node("../Armature")
	if armature == null:
		print_debug("Armature node not found")

#region ----------inputhandler-------------------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("Q"):
			board_created = not board_created
			if board_created:
				var direction_vector = calculate_direction_vector()
				create_board(8, direction_vector)
			else:
				destroy_board()
#endregion

#region ----------Caculate board XZ-------------------
func calculate_direction_vector() -> Vector3:
	var direction_vector: Vector3 = (global_position - target_enemy.global_position).normalized()
	direction_vector.y = 0
	angle = atan2(direction_vector.x, direction_vector.z)
	return direction_vector
#endregion 

#region ----------- Caculate Y spawn POS ---------
# this part is not yet done and full of error, not facing the right direction and not spawning at the right location z,y, need to be fixed later
func Caculate_Y_Point() -> float:
	return min(target_enemy.global_position.y, global_position.y) - lower_value;
#endregion

#region ---------------- Board Creation----------------
func create_board(board_size: int, direction_to_enemy: Vector3) -> void:
	total_instances = board_size * board_size
	multimesh.instance_count = total_instances

	var forward = direction_to_enemy
	var right = Vector3.UP.cross(forward).normalized()
	
	var half_board = (board_size - 1) * spacing * 0.5
	var starting_point = global_position - (forward * half_board) - (right * half_board)
	
	var final_y = Caculate_Y_Point()
	var board_basis = Basis(right, Vector3.UP, -forward).orthonormalized()
	for i: int in range(total_instances):
		var x = i % board_size
		@warning_ignore("integer_division")
		var z = i / board_size
		
		var local_offset = (forward * z * spacing) + (right * x * spacing)
		var final_pos = starting_point + local_offset
		final_pos.y = 2
		
		var xform = Transform3D(Basis(), final_pos)
		multimesh.set_instance_transform(i, xform)
		print_debug(final_pos)

		var color = Color.WHITE if (x + z) % 2 == 0 else Color.BLACK
		multimesh.set_instance_color(i, color)
#endregion
#---------------- Board Destruction----------------
func destroy_board() -> void:
	for i in range(total_instances):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)))
