extends MultiMeshInstance3D

# =======================
#region        VARIABLES
# =======================
@export_subgroup("Settings")
@export var spacing: float = 2.0
@export var spawn_distance: float = 5.0
@export var lower_value: float = 10.0

@onready var player: CharacterBody3D = get_parent()
@onready var armature: Node3D = get_node_or_null("../Armature")

var target_enemy: Node3D = null
var total_instances: int = 0
var board_created: bool = false
#endregion

#region  -----READY-------
func _ready() -> void:
	if armature == null:
		print_debug("Armature node not found")
	if global_position== null:
		print_debug("wtf")
#endregion

#=================================
#region  ----------INPUT---------
#=================================
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("Q"):
			toggle_board()
#endregion

#=================================
func toggle_board() -> void:
	if(target_enemy == null):
		print_debug("where's enemy")
		pass
	board_created = !board_created

	if board_created:
		teleport_to_player()
		var forward = calculate_forward_vector()
		create_board(8, forward)
	else:
		destroy_board()

#=================================
#region   ------TELEPORT-------
#=================================
func teleport_to_player() -> void:
	global_position = player.global_position
#endregion
#=================================
#region     --------VECTOR CALCULATION------
#=================================
func calculate_forward_vector() -> Vector3:
	if target_enemy == null:
		print_debug("no enemy")
		return Vector3.FORWARD

	var forward: Vector3 = global_position - target_enemy.global_position
	forward.y = 0
	forward = forward.normalized()

	# Snap to axis (no diagonals)
	if abs(forward.x) > abs(forward.z):
		forward = Vector3(sign(forward.x), 0, 0)
	else:
		forward = Vector3(0, 0, sign(forward.z))

	print_debug(forward.x, forward.z)
	return forward

#=================================
func calculate_spawn_y() -> float:
	if target_enemy == null:
		return global_position.y

	return min(target_enemy.global_position.y, global_position.y) - lower_value
#endregion
#=================================
#region   --HELPERS---
#=================================
func get_right_vector(forward: Vector3) -> Vector3:
	return forward.cross(Vector3.UP).normalized()
#endregion
#=================================
#region    ----------BOARD CREATION------
#=================================
func create_board(board_size: int, direction: Vector3) -> void:
	total_instances = board_size * board_size
	multimesh.instance_count = total_instances

	var forward = direction.normalized()
	var right = get_right_vector(forward)

	# Center on enemy
	var center = target_enemy.global_position
	center.y = 0

	var half_extent = (board_size - 1) * spacing * 0.5
	var start = center - right * half_extent - forward * half_extent

	for i in total_instances:
		var x = i % board_size
		@warning_ignore("integer_division")
		var z = i / board_size

		var world_pos = start + right * x * spacing + forward * z * spacing
		var local_pos = to_local(world_pos)

		multimesh.set_instance_transform(i, Transform3D(Basis(), local_pos))
		multimesh.set_instance_color(i, get_tile_color(x, z, forward))


func get_tile_color(x: int, z: int, forward: Vector3) -> Color:
	var is_even = (x + z) % 2 == 0

	if forward.x > 0 && forward.z <0:
		return Color.WHITE if is_even else Color.BLACK
	else:
		return Color.BLACK if is_even else Color.WHITE
#endregion


#region  --------BOARD DESTRUCTION------

func destroy_board() -> void:
	for i in total_instances:
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)))
#endregion
