extends MultiMeshInstance3D
@export_subgroup("setting")
@export var tile: Mesh;
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("Q"):
			print_debug("q_pressed");
	

func create_board() -> void:
	pass

func _process(delta: float) -> void:
	pass
	
