extends MultiMeshInstance3D
#region ------var----------
@export_subgroup("setting")
@export var spacing = 3.0
@export var spawn_distance: float = 5.0
@export var Lowest_height: float = 10.0;


var target_enemy: Node3D = null;
var Armature: Node3D;
var total_instances: int;
var Board_Created: bool = false;
var angle;
#endregion

func _ready() -> void:
	Armature = get_node("../Armature")
	if (Armature == null):
		print_debug("shit")
	pass

#region ------------Input handler----------
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("Q"):
			if not Board_Created:
				Board_Created = true
				var Center = Caculate_board_POS()
				create_board(8, Center)
			else:
				Board_Created = false
				Destroy_Board()
#endregion

#region ----------Caculate board transform point---------
func Caculate_board_POS() -> Vector3:
	var Center: Vector3 = Vector3(global_position.x - target_enemy.global_position.x,
	0,
	global_position.z - target_enemy.global_position.z)
	
	Center.normalized()
	
	angle = atan2(Center.x, Center.z);
	return Center;
		
#endregion

func create_board(board_size: int, Center: Vector3) -> void:
	total_instances = board_size * board_size
	multimesh.instance_count = total_instances
	
	var Foward_vector = Vector2((Center.x / Center.length()) * 2, (Center.z / Center.length()) * 2)
	var Right_vector = Vector2(-Foward_vector.y, Foward_vector.x);
	
	var spawn_pos = Center
	for i: int in range(total_instances):
		var x = i % board_size
		@warning_ignore("integer_division")
		var z = i / board_size
		
		var final_pos = target_enemy.position;
		
		# Apply transform (Keeping identity basis/rotation)
		var xform = Transform3D(Basis(), final_pos)
		
		multimesh.set_instance_transform(i, xform)
		
		
		# Chessboard coloring
		var color = Color.WHITE if (x + z) % 2 == 0 else Color.BLACK
		multimesh.set_instance_color(i, color)

# Teleport the board to somewhere else
func Destroy_Board() -> void:
	for i in range(total_instances):
		multimesh.set_instance_transform(i, Transform3D(Basis(), Vector3(9999, 0, 9999)));
	pass
