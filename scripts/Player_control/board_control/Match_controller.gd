extends "res://scripts/Player_control/board_control/board_helper_func.gd"

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

#region INNIT FUNCTIONS
func gen_fen(pieces_on_board: Dictionary) -> String:
	var fen = ""
	
	# starts from Rank 8(7) down to 1(0)... don't question me
	for z in range(7, -1, -1):
		var empty_count = 0
		for x in range(8): # this need change, later board will have dynamic size
			var square = Cords_to_notation(x, z)
			
			if pieces_on_board.has(square):
				if empty_count > 0:
					fen += str(empty_count)
					empty_count = 0
				fen += pieces_on_board[square]
			else:
				empty_count += 1
				
		if empty_count > 0:
			fen += str(empty_count)
		
		if z > 0:
			fen += "/"
	
	#  active color, castling
	fen += " w - - 0 1" # do i even need a halfmove clock?
	return fen
#endregion

func fen_to_board(fen: String):
	piece_placement.clear()
	var ranks = fen.split(" ")[0].split("/")
	for z in range(8): # SUPER DUPER UBER IMPORTANT NUMBER!
		var rank_string = ranks[7 - z]
		var x = 0
		for ch in rank_string:
			if ch.is_valid_int():
				x += ch.to_int()
			else:
				var square = Cords_to_notation(x, z)
				piece_placement[square] = ch
				x += 1
				
func get_legal_moves(square: String) -> Array:
	var piece = piece_placement.get(square)
	var moves = []
	if piece == "P": # will do it after impliment the direction where the board is facing...
		pass
	return moves


func spawn_piece(type: String, square: String) -> void:
	var white = is_white(type)
	var piece_key = type.to_upper()
	
	var piece_instance = scene_map[piece_key].instantiate() as Node3D
	add_child(piece_instance)
	
	piece_instance.global_position = board_to_cord[square]
	piece_instance.global_position.y += 20 # same as in plyerskill script
	put_material(piece_instance, white)
	
	piece_nodes[square] = piece_instance

func put_material(node: Node3D, white: bool):
	var mat = white_material if white else black_material
	node.get_child(0).set_surface_override_material(0, mat)
		
func clear_board() -> void:
	for square in piece_nodes:
		var piece = piece_nodes[square]
		if is_instance_valid(piece):
			piece.queue_free()
	
	piece_nodes.clear()

func load_pieces_from_dict(placement: Dictionary):
	clear_board()
	for square in placement:
		var type = placement[square]
		spawn_piece(type, square)

func test_spawn_starting_board():
	var starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"

	fen_to_board(starting_fen)
	for square in piece_placement:
		var type = piece_placement[square]
		spawn_piece(type, square)
	
	print("Test: Pieces spawned on board.")
