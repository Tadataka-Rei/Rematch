extends StaticBody3D

var square_notation: String = ""
var controller:Node
func _ready() -> void:
	controller = get_tree().get_first_node_in_group("controller")
	if controller:
		print("found controller")
func on_clicked():
	if controller:
		print("Clicked piece at: ", square_notation)
		controller.handle_piece_selection(square_notation)
