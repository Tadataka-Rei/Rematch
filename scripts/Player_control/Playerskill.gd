extends MultiMeshInstance3D

#region -----variables-----
@export_subgroup("setting")
@export var spacing: float = 3.0
@export var spawn_distance: float = 5.0
@export var lowest_height: float = 10.0

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
				var center = calculate_board_position()
				create_board(8, center)
			else:
				destroy_board()
#endregion

#region ----------boardfunctions-------------------
func calculate_board_position() -> Vector3:
	var center: Vector3 = Vector3(
		global_position.x - target_enemy.global_position.x,
		0,
		global_position.z - target_enemy.global_position.z,
	)

	angle = atan2(center.x, center.z)
	return center

#---------------- Board Creation----------------
func create_board(board_size: int, center: Vector3) -> void:
	total_instances = board_size * board_size
	multimesh.instance_count = total_instances

	var forward_vector = Vector2((center.x / center.length()) * 2, (center.z / center.length()) * 2)
	var right_vector: Vector2 = Vector2(-forward_vector.y, forward_vector.x)

	for i: int in range(total_instances):
		var x = i % board_size
		@warning_ignore("integer_division")
		var z = i / board_size

		var final_pos = target_enemy.position
		var xform = Transform3D(Basis(), final_pos)
		multimesh.set_instance_transform(i, xform)

		var color = Color.WHITE if (x + z) % 2 == 0 else Color.BLACK
		multimesh.set_instance_color(i, color)

#---------------- Board Destruction----------------
func destroy_board() -> void:
	for i in range(total_instances):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)))
#endregion
