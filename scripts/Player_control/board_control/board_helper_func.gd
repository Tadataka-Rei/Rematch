extends Node

var ATTACKS = [

	20 , 0, 0, 0, 0, 0, 0,24,  0, 0, 0, 0, 0, 0,20,

	0, 0,20, 0, 0, 0, 0, 0,24,  0, 0, 0, 0, 0,20, 0,

	0, 0, 0,20, 0, 0, 0, 0,24,  0, 0, 0, 0,20, 0, 0,

	0, 0, 0, 0,20, 0, 0, 0,24,  0, 0, 0,20, 0, 0, 0,

	0, 0, 0, 0, 0,20, 0, 0,24,  0, 0,20, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 0,20, 2,24,  2,20, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 0, 2,53,56, 53, 2, 0, 0, 0, 0, 0,

	0,24,24,24,24,24,24,56, 0,56,24,24,24,24,24,24,

	0, 0, 0, 0, 0, 0, 2,53,56, 53, 2, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 0,20, 2,24,  2,20, 0, 0, 0, 0, 0, 0,

	0, 0, 0, 0,20, 0, 0,24,  0, 0,20, 0, 0, 0, 0, 0,

	0, 0, 0,20, 0, 0, 0,24,  0, 0, 0,20, 0, 0, 0, 0,

	0, 0,20, 0, 0, 0, 0,24,  0, 0, 0, 0,20, 0, 0, 0,

	0,20, 0, 0, 0, 0, 0,24,  0, 0, 0, 0, 0,20, 0, 0, 20

	];
var pawnEvalBlack = [
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
	[0.5,  1.0,  1.0, -2.0, -2.0,  1.0,  1.0,  0.5],
	[0.5, -0.5, -1.0,  0.0,  0.0, -1.0, -0.5,  0.5],
	[0.0,  0.0,  0.0,  2.0,  2.0,  0.0,  0.0,  0.0],
	[0.5,  0.5,  1.0,  2.5,  2.5,  1.0,  0.5,  0.5],
	[1.0,  1.0,  2.0,  3.0,  3.0,  2.0,  1.0,  1.0],
	[5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0],
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
];

var bishopEvalBlack = [
	[ -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0],
	[ -1.0,  0.5,  0.0,  0.0,  0.0,  0.0,  0.5, -1.0],
	[ -1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0, -1.0],
	[ -1.0,  0.0,  1.0,  1.0,  1.0,  1.0,  0.0, -1.0],
	[ -1.0,  0.5,  0.5,  1.0,  1.0,  0.5,  0.5, -1.0],
	[ -1.0,  0.0,  0.5,  1.0,  1.0,  0.5,  0.0, -1.0],
	[ -1.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -1.0],
	[ -2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0]
];

var rookEvalBlack = [
	[  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0],
	[ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
	[ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
	[ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
	[ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
	[ -0.5,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0, -0.5],
	[  0.5,  1.0,  1.0,  1.0,  1.0,  1.0,  1.0,  0.5], 
	[  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
]

var kingEvalBlack = [
	[  2.0,  3.0,  1.0,  0.0,  0.0,  1.0,  3.0,  2.0 ],
	[  2.0,  2.0,  0.0,  0.0,  0.0,  0.0,  2.0,  2.0 ],
	[ -1.0, -2.0, -2.0, -2.0, -2.0, -2.0, -2.0, -1.0],
	[ -2.0, -3.0, -3.0, -4.0, -4.0, -3.0, -3.0, -2.0],
	[ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[ -3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0]
];
var knightEvalBlack = [
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0], # Back Rank (Black)
	[-4.0, -2.0,  0.0,  0.5,  0.5,  0.0, -2.0, -4.0],
	[-3.0,  0.5,  1.0,  1.5,  1.5,  1.0,  0.5, -3.0],
	[-3.0,  0.0,  1.5,  2.0,  2.0,  1.5,  0.0, -3.0],
	[-3.0,  0.5,  1.5,  2.0,  2.0,  1.5,  0.5, -3.0],
	[-3.0,  0.0,  1.0,  1.5,  1.5,  1.0,  0.0, -3.0],
	[-4.0, -2.0,  0.0,  0.0,  0.0,  0.0, -2.0, -4.0],
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0]  # Front Rank (Black)
]
var piece_values = {"P": 10, "N": 30, "B": 30, "R": 50, "Q": 90, "K": 900}
# note to self: store {"a1": Vector3(x, y, z), "b1": ... }
var board_to_cord: Dictionary = {} # square name to corrd
var piece_placement: Dictionary = {} # for pieces pos but in FEN
var piece_nodes: Dictionary = {} # reference to the node using FEN I'll have hemmoroid after this

func is_white(type: String) -> bool:
	return type == type.to_upper()
func Cords_to_notation(x: int, z: int) -> String:
	# Ensure x is between 0 and 7 before accessing the string index
	if x < 0 or x > 7 or z < 0 or z > 7:
		return "" # Return empty if out of bounds
	
	var files = "abcdefgh"
	return files[x] + str(z + 1)

func update_board_geo(square_name: String, global_pos: Vector3):# add into the DICK
	board_to_cord[square_name] = global_pos
	
func notation_to_index(notation: String) -> int:
	var files = "abcdefgh"
	var x = files.find(notation[0])
	var z = notation[1].to_int() - 1
	return z * 16 + x
	
func is_on_board(x: int, z: int) -> bool:
	return x >= 0 and x < 8 and z >= 0 and z < 8

func notation_to_coords(notation: String) -> Vector2:
	var files = "abcdefgh"
	var x = files.find(notation[0])
	var z = notation[1].to_int() - 1
#	var z = 8 - notation[1].to_int()
	return Vector2(x, z)
	
func apply_simulated_move(from: String, to: String):
	piece_placement[to] = piece_placement[from]
	piece_placement.erase(from)
	
func get_piece_stats_value(type: String, x: int, z: int) -> float:
	var table = []
	var p_upper = type.to_upper()
	var white = is_white(type)

	match p_upper:
		"P": table = pawnEvalBlack
		"N": table = knightEvalBlack # Use the new Knight table
		"B": table = bishopEvalBlack
		"R": table = rookEvalBlack
		"K": table = kingEvalBlack
		"Q": table = bishopEvalBlack 
		_: return 0.0

	# Ensure we stay in bounds
	x = clamp(x, 0, 7)
	z = clamp(z, 0, 7)

	var lookup_z : int
	if white:
		lookup_z = (z)
	else:
		lookup_z = (7- z)
	
	return table[lookup_z][x]
