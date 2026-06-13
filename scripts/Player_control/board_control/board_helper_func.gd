extends Node

var ATTACKS = [

	20, 0, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 0, 20,

	0, 0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0,

	0, 0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0,

	0, 0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0,

	0, 0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0,

	0, 24, 24, 24, 24, 24, 24, 56, 0, 56, 24, 24, 24, 24, 24, 24,

	0, 0, 0, 0, 0, 0, 2, 53, 56, 53, 2, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 0, 20, 2, 24, 2, 20, 0, 0, 0, 0, 0, 0,

	0, 0, 0, 0, 20, 0, 0, 24, 0, 0, 20, 0, 0, 0, 0, 0,

	0, 0, 0, 20, 0, 0, 0, 24, 0, 0, 0, 20, 0, 0, 0, 0,

	0, 0, 20, 0, 0, 0, 0, 24, 0, 0, 0, 0, 20, 0, 0, 0,

	0, 20, 0, 0, 0, 0, 0, 24, 0, 0, 0, 0, 0, 20, 0, 0, 20

	];
var pawnEvalBlack = [
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0], # Back Rank (Starting row is empty for pawns)
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0], # Starting squares: Net 0 value
	[0.5,  0.5,  1.0,  1.5,  1.5,  1.0,  0.5,  0.5], # Moving forward slightly is good
	[1.0,  1.0,  2.0,  3.5,  3.5,  2.0,  1.0,  1.0], # Strong reward for pushing center squares
	[2.0,  2.0,  3.0,  4.0,  4.0,  3.0,  2.0,  2.0],
	[3.0,  3.0,  4.0,  5.0,  5.0,  4.0,  3.0,  3.0],
	[5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0,  5.0], # Close to promotion
	[0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0,  0.0]
]


var bishopEvalBlack = [
	[-2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0],
	[-1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.5, -1.0],
	[-1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0],
	[-1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0, -1.0],
	[-1.0, 0.5, 0.5, 1.0, 1.0, 0.5, 0.5, -1.0],
	[-1.0, 0.0, 0.5, 1.0, 1.0, 0.5, 0.0, -1.0],
	[-1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0],
	[-2.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -2.0]
];

var rookEvalBlack = [
	[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
	[-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
	[-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
	[-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
	[-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
	[-0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -0.5],
	[0.5, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.5],
	[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
]

var kingEvalBlack = [
	[2.0, 3.0, 1.0, 0.0, 0.0, 1.0, 3.0, 2.0],
	[2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0],
	[-1.0, -2.0, -2.0, -2.0, -2.0, -2.0, -2.0, -1.0],
	[-2.0, -3.0, -3.0, -4.0, -4.0, -3.0, -3.0, -2.0],
	[-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0],
	[-3.0, -4.0, -4.0, -5.0, -5.0, -4.0, -4.0, -3.0]
];

var knightEvalBlack = [
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0], # Starting Back Rank
	[-4.0, -2.0,  0.0,  0.0,  0.0,  0.0, -2.0, -4.0], # Row 1
	[-3.0,  0.0,  1.0,  1.5,  1.5,  1.0,  0.0, -3.0], # Developing to sides/center
	[-3.0,  0.5,  1.5,  2.0,  2.0,  1.5,  0.5, -3.0], 
	[-3.0,  0.5,  1.5,  2.0,  2.0,  1.5,  0.5, -3.0],
	[-3.0,  0.0,  1.0,  1.5,  1.5,  1.0,  0.0, -3.0],
	[-4.0, -2.0,  0.0,  0.5,  0.5,  0.0, -2.0, -4.0],
	[-5.0, -4.0, -3.0, -3.0, -3.0, -3.0, -4.0, -5.0]
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

func update_board_geo(square_name: String, global_pos: Vector3): # add into the DICK
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
	
func get_piece_stats_value(type: String, x: int, z: int) -> float:
	var table = []
	var p_upper = type.to_upper()
	var white = is_white(type)

	match p_upper:
		"P": table = pawnEvalBlack
		"N": table = knightEvalBlack
		"B": table = bishopEvalBlack
		"R": table = rookEvalBlack
		"K": table = kingEvalBlack
		"Q": table = bishopEvalBlack
		_: return 0.0

	x = clamp(x, 0, 7)
	z = clamp(z, 0, 7)

	var lookup_z: int
	if white:
		lookup_z = 7 - z  
	else:
		lookup_z = z 
	
	return table[lookup_z][x]


var en_passant_square: String = ""

func apply_simulated_move(from: String, to: String):
	var piece = piece_placement[from]
	var from_coords = notation_to_coords(from)
	var to_coords = notation_to_coords(to)
	
	if piece.to_upper() == "P" and to == en_passant_square:
		var target_z = from_coords.y 
		var victim_sq = Cords_to_notation(int(to_coords.x), int(target_z))
		piece_placement.erase(victim_sq)
		
	# Execute the move
	piece_placement[to] = piece
	piece_placement.erase(from)
	if piece.to_upper() == "P":
		if (is_white(piece) and to_coords.y == 7) or (not is_white(piece) and to_coords.y == 0):
			piece_placement[to] = "Q" if is_white(piece) else "q"
	
	if piece.to_upper() == "P" and abs(from_coords.y - to_coords.y) == 2:
		var dir = 1 if is_white(piece) else -1
		en_passant_square = Cords_to_notation(int(from_coords.x), int(from_coords.y + dir))
	else:
		en_passant_square = ""
