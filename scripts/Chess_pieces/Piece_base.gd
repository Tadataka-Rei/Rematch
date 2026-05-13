extends StaticBody3D

var square_notation: String = ""
var controller: Node

func _ready() -> void:
	add_to_group("pieces")
	controller = get_tree().get_first_node_in_group("controller")

func on_clicked():
	if controller:
		controller.handle_piece_selection(square_notation)
