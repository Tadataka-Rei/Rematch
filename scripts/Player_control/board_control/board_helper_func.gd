extends Node
# note to self: store {"a1": Vector3(x, y, z), "b1": ... }
var board_to_cord: Dictionary = {} # square name to corrd
var piece_placement: Dictionary = {} # for pieces pos but in FEN
var piece_nodes: Dictionary = {} # reference to the node using FEN I'll have hemmoroid after this

func is_white(type: String) -> bool:
	return type == type.to_upper()
func Cords_to_notation(x: int, z: int) -> String:#Convert global cord to board cord
	var files = "abcdefgh"
	return files[x] + str(z + 1)
func update_board_geo(square_name: String, global_pos: Vector3):# add into the DICK
	board_to_cord[square_name] = global_pos
