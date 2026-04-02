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
				create_board(12, direction_vector)
			else:
				destroy_board()
#endregion

#region ----------Caculate board XZ-------------------
func calculate_direction_vector() -> Vector3:
	if target_enemy == null:
		return Vector3.FORWARD

	var dir: Vector3 = (target_enemy.global_position - global_position)
	dir.y = 0
	dir = dir.normalized()

	# Snap to closest axis (remove diagonals)
	if abs(dir.x) > abs(dir.z):
		dir = Vector3(sign(dir.x), 0, 0) # left/right
	else:
		dir = Vector3(0, 0, sign(dir.z)) # forward/back

	angle = atan2(dir.x, dir.z)
	return dir

#region ----------- Caculate Y spawn POS ---------
func calculate_spawn_y() -> float:
	if target_enemy == null:
		return global_position.y
	return min(target_enemy.global_position.y, global_position.y) - lower_value
#endregion

#region ---------------- Board Creation----------------
func create_board(board_size: int, direction_to_enemy: Vector3) -> void:
	total_instances = board_size * board_size
	multimesh.instance_count = total_instances

	var forward = direction_to_enemy.normalized()
	var right = forward.cross(Vector3.UP).normalized()
	var up = Vector3.UP

	# Center on enemy
	var world_center = target_enemy.global_position
	world_center.y = 0

	var half_extent = (board_size - 1) * spacing * 0.5
	var starting_point = world_center - (right * half_extent) - (forward * half_extent)

	var board_basis = Basis(right, up, forward).orthonormalized()

	for i: int in range(total_instances):
		var x = i % board_size
		@warning_ignore("integer_division")
		var z = i / board_size

		var world_pos = starting_point + (right * x * spacing) + (forward * z * spacing)
		var local_pos = to_local(world_pos)

		var xform = Transform3D(Basis(), local_pos)
		multimesh.set_instance_transform(i, xform)

		var color = Color.WHITE if (x + z) % 2 == 0 else Color.BLACK
		multimesh.set_instance_color(i, color)
#endregion
#---------------- Board Destruction----------------
func destroy_board() -> void:
	for i in range(total_instances):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)))
