extends Node

@export_group("Piece Templates")
@export var pawn_scene: PackedScene
@export var rook_scene: PackedScene
@export var knight_scene: PackedScene
@export var bishop_scene: PackedScene
@export var queen_scene: PackedScene
@export var king_scene: PackedScene

@export_group("Materials")
@export var white_material: StandardMaterial3D
@export var black_material: StandardMaterial3D

# Penis
@onready var scene_map = {
	"P": pawn_scene, "R": rook_scene, "N": knight_scene,
	"B": bishop_scene, "Q": queen_scene, "K": king_scene
}
# note to self: store {"a1": Vector3(x, y, z), "b1": ... }
var board_data: Dictionary = {}
var piece_placement: Dictionary = {}
var piece_nodes: Dictionary = {}
var active_pieces: Dictionary = {}

func generate_fen(pieces_on_board: Dictionary) -> String:
	var fen = ""
	
	# starts from Rank 8(7) down to 1(0)
	for z in range(7, -1, -1):
		var empty_count = 0
		for x in range(8):
			var square = _coords_to_notation(x, z)
			
			if pieces_on_board.has(square):
				if empty_count > 0:
					fen += str(empty_count)
					empty_count = 0
				fen += pieces_on_board[square] # e.g., 'P', 'k', 'B'
			else:
				empty_count += 1
				
		if empty_count > 0:
			fen += str(empty_count)
		
		if z > 0:
			fen += "/"
	
	#  active color, castling
	fen += " w - - 0 1" # this is white turn
	return fen


func setup_starting_board():
	# starting position
	var starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
	parse_fen(starting_fen)


func parse_fen(fen: String):
	piece_placement.clear()
	var ranks = fen.split(" ")[0].split("/")
	for z in range(8):
		var rank_string = ranks[7 - z] # FEN is Rank 8 to 1
		var x = 0
		for char in rank_string:
			if char.is_valid_int():
				x += char.to_int()
			else:
				var square = _coords_to_notation(x, z)
				piece_placement[square] = char
				x += 1
				
func get_legal_moves(square: String) -> Array:
	var piece = piece_placement.get(square)
	var moves = []
	if piece == "P" or piece == "p":
		# Logic for pawn: move forward 1, capture diagonal
		pass
	# ... etc
	return moves
	
func _coords_to_notation(x: int, z: int) -> String:
	var files = "abcdefgh"
	return files[x] + str(z + 1)

func update_board_geometry(square_name: String, global_pos: Vector3):
	board_data[square_name] = global_pos
	
func spawn_piece(type: String, square: String) -> void:
	var is_white = type == type.to_upper()
	var piece_key = type.to_upper()
	
	if not scene_map.has(piece_key):
		return
	
	var piece_instance = scene_map[piece_key].instantiate() as Node3D
	add_child(piece_instance)
	
	if board_data.has(square):
		piece_instance.global_position = board_data[square]
	_apply_piece_material(piece_instance, is_white)
	
	active_pieces[square] = piece_instance

func _apply_piece_material(node: Node3D, is_white: bool):
	var mat = white_material if is_white else black_material
	
	for child in node.find_children("*", "MeshInstance3D", true):
		child.set_surface_override_material(0, mat)
		
func clear_board():
	for square in active_pieces:
		active_pieces[square].queue_free()
	active_pieces.clear()

func load_pieces_from_dict(placement: Dictionary):
	clear_board()
	for square in placement:
		var type = placement[square]
		spawn_piece(type, square)
