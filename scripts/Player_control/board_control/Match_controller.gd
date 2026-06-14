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
@export var capture_material: StandardMaterial3D
# Penis

@export var indicator_mesh: PackedScene # A simple glowing circle or sphere
@onready var move_indicators: Array = []
@onready var selected_square: String = ""
var is_player_turn: bool = true
var moved_pieces: Dictionary = {} # Tracks if a square has been moved from: {"e1": true}

@onready var board_forward_vector: Vector3 = Vector3.FORWARD
var highlighted_capture_pieces: Array[String] = []
@onready var scene_map = {
	"P": pawn_scene, "R": rook_scene, "N": knight_scene,
	"B": bishop_scene, "Q": queen_scene, "K": king_scene
}


#region INNIT FUNCTIONS
func _ready():
	prepare_indicators()
	
func gen_fen(pieces_on_board: Dictionary) -> String:
	var fen = ""
	
	# starts from Rank 8(7) down to 1(0), i'm dumb at math so the board is created upside down
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

func spawn_piece(type: String, square: String) -> void:
	var white = is_white(type) # everytime i call this function, i feel racist
	var piece_key = type.to_upper()
	
	var piece_instance = scene_map[piece_key].instantiate()
	add_child(piece_instance)
	
	piece_instance.global_position = board_to_cord[square]
	piece_instance.global_position.y += 19.7
	
	var face_dir: Vector3
	if (white):
		face_dir = board_forward_vector
	else:
		face_dir = - board_forward_vector
		
	face_dir.y = 0
	if face_dir != Vector3.ZERO:
		piece_instance.look_at(piece_instance.global_position + face_dir, Vector3.UP)
		
	piece_instance.square_notation = square
	piece_instance.add_to_group("pieces")
	
	put_material(piece_instance, white)
	piece_nodes[square] = piece_instance

func is_square_attacked(target_x: int, target_z: int, attackers_are_white: bool) -> bool:
	var target_sq = Cords_to_notation(target_x, target_z)
	
	for sq in piece_placement:
		var piece = piece_placement[sq]
		if is_white(piece) == attackers_are_white:
			var coords = notation_to_coords(sq)
			var type = piece.to_upper()
			
			# We check "pseudo-legal" moves for the attacker
			var possible_attacks = []
			match type:
				"P": # Pawns attack diagonally
					var dir = 1 if attackers_are_white else -1
					possible_attacks = [Cords_to_notation(coords.x - 1, coords.y + dir), Cords_to_notation(coords.x + 1, coords.y + dir)]
				"N": possible_attacks = get_stepping_moves(coords.x, coords.y, attackers_are_white, [Vector2(1, 2), Vector2(1, -2), Vector2(-1, 2), Vector2(-1, -2), Vector2(2, 1), Vector2(2, -1), Vector2(-2, 1), Vector2(-2, -1)])
				"K": possible_attacks = get_stepping_moves(coords.x, coords.y, attackers_are_white, [Vector2(1, 1), Vector2(1, 0), Vector2(1, -1), Vector2(0, 1), Vector2(0, -1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)])
				"R": possible_attacks = get_sliding_moves(coords.x, coords.y, attackers_are_white, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)])
				"B": possible_attacks = get_sliding_moves(coords.x, coords.y, attackers_are_white, [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)])
				"Q": possible_attacks = get_sliding_moves(coords.x, coords.y, attackers_are_white, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)])
			
			if possible_attacks.has(target_sq):
				return true
	return false
	
func get_legal_moves(square: String) -> Array:
	var moves = []
	var piece = piece_placement.get(square)
	if piece == null: return []

	var coords = notation_to_coords(square)
	var x = coords.x
	var z = coords.y
	var white = is_white(piece)
	var type = piece.to_upper()

	match type:
		"P": moves = get_pawn_moves(x, z, white)
		"N": moves = get_stepping_moves(x, z, white, [Vector2(1, 2), Vector2(1, -2), Vector2(-1, 2), Vector2(-1, -2), Vector2(2, 1), Vector2(2, -1), Vector2(-2, 1), Vector2(-2, -1)])
		"K":
			moves = get_stepping_moves(x, z, white, [Vector2(1, 1), Vector2(1, 0), Vector2(1, -1), Vector2(0, 1), Vector2(0, -1), Vector2(-1, 1), Vector2(-1, 0), Vector2(-1, -1)])
			
			# CASTLING LOGIC (King starts at x=3)
			if not moved_pieces.has(square):
				if not is_square_attacked(x, z, !white):
					var rook_h_sq = Cords_to_notation(7, z)
					if piece_placement.has(rook_h_sq) and not moved_pieces.has(rook_h_sq):
						if not piece_placement.has(Cords_to_notation(4, z)) and \
						not piece_placement.has(Cords_to_notation(5, z)) and \
						not piece_placement.has(Cords_to_notation(6, z)):
							# King crosses x=4 and ends at x=5
							if not is_square_attacked(4, z, !white) and not is_square_attacked(5, z, !white):
								moves.append(Cords_to_notation(5, z))
								
					# --- QUEENSIDE (Towards A-File, x=0) ---
					var rook_a_sq = Cords_to_notation(0, z)
					if piece_placement.has(rook_a_sq) and not moved_pieces.has(rook_a_sq):
						# Path: squares at x=1, 2 must be empty
						if not piece_placement.has(Cords_to_notation(1, z)) and \
						not piece_placement.has(Cords_to_notation(2, z)):
							# King crosses x=2 and ends at x=1
							if not is_square_attacked(2, z, !white) and not is_square_attacked(1, z, !white):
								moves.append(Cords_to_notation(1, z))
		
		"R": moves = get_sliding_moves(x, z, white, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)])
		"B": moves = get_sliding_moves(x, z, white, [Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)])
		"Q": moves = get_sliding_moves(x, z, white, [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1), Vector2(1, 1), Vector2(1, -1), Vector2(-1, 1), Vector2(-1, -1)])

	return moves

# --- PIECE SPECIFIC LOGIC ---

func get_stepping_moves(x: int, z: int, white: bool, offsets: Array) -> Array:
	var moves = []
	for off in offsets:
		var target_x = x + off.x
		var target_z = z + off.y
		if is_on_board(target_x, target_z):
			var target_sq = Cords_to_notation(target_x, target_z)
			if not piece_placement.has(target_sq) or is_white(piece_placement[target_sq]) != white:
				moves.append(target_sq)
	return moves

func get_sliding_moves(x: int, z: int, white: bool, directions: Array) -> Array:
	var moves = []
	for dir in directions:
		for i in range(1, 8):
			var target_x = x + (dir.x * i)
			var target_z = z + (dir.y * i)
			
			if not is_on_board(target_x, target_z): break
			
			var target_sq = Cords_to_notation(target_x, target_z)
			if not piece_placement.has(target_sq):
				moves.append(target_sq)
			else:
				# Hit a piece: if enemy, we can take it, then stop. If friend, just stop.
				if is_white(piece_placement[target_sq]) != white:
					moves.append(target_sq)
				break
	return moves

func get_pawn_moves(x: int, z: int, white: bool) -> Array:
	var moves = []
	var dir = -1 if white else 1
	var start_rank = 6 if white else 1
	
	var f1 = Cords_to_notation(x, z + dir)
	if is_on_board(x, z + dir) and not piece_placement.has(f1):
		moves.append(f1)
		var f2 = Cords_to_notation(x, z + (dir * 2))
		if z == start_rank and not piece_placement.has(f2):
			moves.append(f2)
			
	for side in [-1, 1]:
		var cap_x = x + side
		var cap_z = z + dir
		if is_on_board(cap_x, cap_z):
			var cap_sq = Cords_to_notation(cap_x, cap_z)
			# Normal capture
			if piece_placement.has(cap_sq) and is_white(piece_placement[cap_sq]) != white:
				moves.append(cap_sq) # En Passant capture check
			elif cap_sq == en_passant_square:
				moves.append(cap_sq)
	return moves

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
	var starting_fen = "RNBKQBNR/PPPPPPPP/8/8/8/8/pppppppp/rnbkqbnr"

	fen_to_board(starting_fen)
	for square in piece_placement:
		var type = piece_placement[square]
		spawn_piece(type, square)
	
	print("Test: Pieces spawned on board.")

func prepare_indicators():
	for i in range(27): # Max possible moves for a Queen
		var indicator = indicator_mesh.instantiate() as Node3D
		indicator.visible = false
		add_child(indicator)
		move_indicators.append(indicator)
		
		
func handle_piece_selection(square: String):
	if not is_player_turn: return
	
	if highlighted_capture_pieces.has(square):
		perform_move(selected_square, square)
		is_player_turn = false # Or trigger AI
		return

	var type = piece_placement.get(square, "")
	if type == "": return
	
	# Check if it's the player's piece (White)
	# Assuming White is uppercase in your FEN logic
	if not is_white(type):
		return

	hide_indicators() # This will now also reset materials
	selected_square = square
	var moves = get_legal_moves(square)
	
	for i in range(moves.size()):
		var target_sq = moves[i]
		
		# If there is an enemy piece here, highlight the piece instead of showing a circle
		if piece_placement.has(target_sq):
			highlight_piece_for_capture(target_sq)
		elif i < move_indicators.size():
			move_indicators[i].global_position = board_to_cord[target_sq]
			move_indicators[i].global_position.y += 20
			move_indicators[i].visible = true
			move_indicators[i].set_meta("target_square", target_sq)

func highlight_piece_for_capture(square: String):
	if piece_nodes.has(square):
		var piece_node = piece_nodes[square]
		piece_node.get_child(0).set_surface_override_material(0, capture_material)
		highlighted_capture_pieces.append(square)

# --- AI & MINIMAX LOGIC ---

func _input(event):
	if event.is_action_pressed("ui_accept") and not is_player_turn:
		execute_ai_turn()

func execute_ai_turn():
	var best_move = calculate_best_move(3) # Depth 3
	if best_move:
		perform_move(best_move.from, best_move.to)
	is_player_turn = true

func calculate_best_move(depth: int):
	var best_score = 99999 # Start high for Black (minimizing)
	var alpha = -100000
	var beta = 100000
	var best_moves: Array = [] # Change this to an array to hold tied moves
	
	var possible_moves = get_all_valid_moves(false) # Black's moves
	
	for move in possible_moves:
		var temp_state = piece_placement.duplicate()
		var temp_ep = en_passant_square
		
		apply_simulated_move(move.from, move.to)
		
		var score = minimax(depth - 1, alpha, beta, true)
		score += randf_range(-0.05, 0.05)
		
		piece_placement = temp_state
		en_passant_square = temp_ep
		
		if score < best_score:
			best_score = score
			best_moves = [move]
		elif abs(score - best_score) < 0.1:
			best_moves.append(move) # Move is essentially equal, add to choices
			
			beta = min(beta, best_score)
			
	if best_moves.size() > 0:
		return best_moves.pick_random() # Pick a random move from the best options!
	return null
	
func minimax(depth: int, alpha: float, beta: float, is_maximizing: bool) -> float:
	if depth == 0:
		# evaluate_board() returns positive for White, negative for Black
		return evaluate_board()
	
	var moves = get_all_valid_moves(is_maximizing) # Get moves for current player
	
	if is_maximizing: # White's Turn
		var max_eval = -99999
		for m in moves:
			var temp = piece_placement.duplicate()
			apply_simulated_move(m.from, m.to) # Actually move the piece
			var eval = minimax(depth - 1, alpha, beta, !is_maximizing)
			piece_placement = temp # Undo the move
			
			max_eval = max(max_eval, eval)
			alpha = max(alpha, eval)
			if beta <= alpha:
				break
		return max_eval
	else: # Black's Turn (AI)
		var min_eval = 99999
		for m in moves:
			var temp = piece_placement.duplicate()
			var temp_ep = en_passant_square
			
			apply_simulated_move(m.from, m.to)
			var eval = minimax(depth - 1, alpha, beta, true)
			
			piece_placement = temp
			en_passant_square = temp_ep
			
			min_eval = min(min_eval, eval)
			beta = min(beta, eval)
			if beta <= alpha:
				break
		return min_eval

func evaluate_board() -> float:
	var score = 0.0
	
	for sq in piece_placement:
		var p = piece_placement[sq]
		var coords = notation_to_coords(sq)
		var x = int(coords.x)
		var z = int(coords.y)
		
		var val = piece_values.get(p.to_upper(), 0)
		
		# 2. Positional Bonus
		var pos_bonus = get_piece_stats_value(p, x, z)
		
		var idx = notation_to_index(sq)
		var attack_bonus = ATTACKS[idx] if idx < ATTACKS.size() else 0
		
		var total_val = val + (pos_bonus * 0.5) + (attack_bonus * 0.1)
		
		if is_white(p):
			score += total_val
		else:
			score -= total_val
			
	return score

# --- HELPER UTILITIES ---

func simulate_move(from: String, to: String):
	var new_board = piece_placement.duplicate()
	new_board[to] = new_board[from]
	new_board.erase(from)
	return new_board

func perform_move(from: String, to: String):
	var piece_char = piece_placement[from]
	var from_coords = notation_to_coords(from)
	var to_coords = notation_to_coords(to)
	var white = is_white(piece_char)
	
	# --- Detect Castling ---
	if piece_char.to_upper() == "K" and abs(from_coords.x - to_coords.x) == 2:
		var rank = from_coords.y
		var is_kingside = to_coords.x > from_coords.x
		var rook_from: String
		var rook_to: String
		
		if is_kingside:
			rook_from = Cords_to_notation(7, rank)
			rook_to = Cords_to_notation(4, rank)
		else:
			rook_from = Cords_to_notation(0, rank)
			rook_to = Cords_to_notation(2, rank)
			
		if piece_placement.has(rook_from):
			piece_placement[rook_to] = piece_placement[rook_from]
			piece_placement.erase(rook_from)
			
			if piece_nodes.has(rook_from):
				var rook_node = piece_nodes[rook_from]
				rook_node.global_position = board_to_cord[rook_to]
				rook_node.global_position.y += 19.7
				rook_node.square_notation = rook_to
				piece_nodes[rook_to] = rook_node
				piece_nodes.erase(rook_from)
				
	# --- En Passant ---
	if piece_char.to_upper() == "P" and to == en_passant_square:
		var victim_sq = Cords_to_notation(int(to_coords.x), int(from_coords.y))
		
		piece_placement.erase(victim_sq)
		
		if piece_nodes.has(victim_sq):
			var victim_node = piece_nodes[victim_sq]
			if is_instance_valid(victim_node):
				victim_node.queue_free()
			piece_nodes.erase(victim_sq)

	# ---------------------------------------------------------
	# FIX: Check the victim type BEFORE updating piece_placement
	# ---------------------------------------------------------
	var victim_type = piece_placement.get(to, "").to_upper()
	
	moved_pieces[from] = true
	piece_placement[to] = piece_char
	piece_placement.erase(from)
	
	# --- Capture Handling + King Destruction ---
	if piece_nodes.has(to):
		# If the captured piece was a King
		if victim_type == "K":
			print("King has been captured! Destroying the domain...")
			var victim = piece_nodes[to]
			if is_instance_valid(victim):
				victim.queue_free()
			piece_nodes.erase(to)
			clear_board()
			
			# Tell the board owner to destroy the MultiMesh/grid
			var player_skill = get_tree().get_nodes_in_group("player_skill")
			if not player_skill.is_empty():
				player_skill[0].force_destroy_board()
			elif get_parent() != null and get_parent().has_method("force_destroy_board"):
				get_parent().force_destroy_board()
			
			# Clean up UI highlights leftover before cutting execution short
			selected_square = ""
			hide_indicators()
			return
		
		# Regular capture logic
		var victim = piece_nodes[to]
		if is_instance_valid(victim):
			victim.queue_free()
		piece_nodes.erase(to)

	# Move piece node
	if piece_nodes.has(from):
		var node = piece_nodes[from]
		node.global_position = board_to_cord[to]
		node.global_position.y += 19.7
		node.square_notation = to
		piece_nodes[to] = node
		piece_nodes.erase(from)
	
	# en passant target
	if piece_char.to_upper() == "P" and abs(from_coords.y - to_coords.y) == 2:
		var dir = 1 if white else -1
		en_passant_square = Cords_to_notation(int(from_coords.x), int(from_coords.y + dir))
	else:
		en_passant_square = ""
	
	# Promotion
	if piece_char.to_upper() == "P":
		if (white and to_coords.y == 0) or (not white and to_coords.y == 7):
			promote_pawn(to, white)
	
	selected_square = ""
	hide_indicators()

func promote_pawn(square: String, white: bool):
	if piece_nodes.has(square):
		var pawn_node = piece_nodes[square]
		if is_instance_valid(pawn_node):
			pawn_node.queue_free()
		piece_nodes.erase(square)
	
	var promo_char = "Q" if white else "q"
	piece_placement[square] = promo_char
	
	spawn_piece(promo_char, square)
	print("Pawn promoted to Queen at: ", square)

func hide_indicators():
	for ind in move_indicators:
		ind.visible = false
	
	# Reset highlighted piece
	for sq in highlighted_capture_pieces:
		if piece_nodes.has(sq):
			var type = piece_placement.get(sq, "")
			put_material(piece_nodes[sq], is_white(type))
	
	highlighted_capture_pieces.clear()

func get_all_valid_moves(white: bool) -> Array:
	var all_moves = []
	for sq in piece_placement:
		if is_white(piece_placement[sq]) == white:
			var moves = get_legal_moves(sq)
			for m in moves:
				all_moves.append({"from": sq, "to": m})
	return all_moves
