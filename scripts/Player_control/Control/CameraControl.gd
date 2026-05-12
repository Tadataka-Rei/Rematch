extends Node3D

enum CameraStates {ThirdPov, TopDownPOV}

@onready var springarm: SpringArm3D = $SpringArm3D
@onready var Camera: Camera3D  = $SpringArm3D/Camera3D
@onready var CameraMode: CameraStates
@onready var is_dragging = false

@export_category("topdown setting")
@export var drag_sensitivity = 0.05
@export var zoom_speed = 0.1
@export var min_fov = 20.0
@export var max_fov = 90.0

@export_category("thirdPOV setting")
@export var cameraPanSpeed: float = 0.0015
var controller: Node
@onready var mouse : Vector2

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	CameraMode= CameraStates.ThirdPov
	controller = get_tree().get_first_node_in_group("controller")
	
func thirdPOV(event: InputEvent) ->void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * cameraPanSpeed)
		springarm.rotate_x(-event.relative.y * cameraPanSpeed)
		springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-70), deg_to_rad(30))
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func topdownPov(event: InputEvent) -> void:
	# DRAG DETECTION
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.is_pressed()
		
		# Panning
	if is_dragging and event is InputEventMouseMotion:
		global_translate(Vector3(-event.relative.x * drag_sensitivity, 0, -event.relative.y * drag_sensitivity))
	
	# ZOOM (Mouse Wheel)
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Camera.fov = clamp(Camera.fov - zoom_speed, min_fov, max_fov)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Camera.fov = clamp(Camera.fov + zoom_speed, min_fov, max_fov)
#region Input Handler
func _input(event: InputEvent) -> void:
	if(CameraMode == CameraStates.ThirdPov):
		thirdPOV(event)
	else:
		topdownPov(event)
		select_piece(event)
#endregion

func Camera_state_toggle() -> void:
	if (CameraMode == CameraStates.ThirdPov):# current is 3rd pov so change to top down
		Change_to_topdown()
	else:
		Change_to_thirdPOV()

func Change_to_topdown() -> void:
	springarm.spring_length = 0
	Camera.top_level = true
	top_level =true
	Camera.rotation.x = deg_to_rad(-90)
	Camera.rotation.y = 0
	Camera.rotation.z = 0
	position.y += 20
	CameraMode = CameraStates.TopDownPOV
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
	

func Change_to_thirdPOV() -> void:
	Camera.set_as_top_level(false)
	springarm.spring_length = 3
	Camera.rotation = Vector3.ZERO
	CameraMode = CameraStates.ThirdPov

@onready var camera = self
func select_piece(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		
		var ray_length = 1000
		var from = Camera.project_ray_origin(mouse_pos)
		var to = from + Camera.project_ray_normal(mouse_pos) * ray_length
		
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		var result = space.intersect_ray(ray_query)
		
		if result:
			var collider = result.collider
			# 1. Check if we clicked a piece
			if collider.has_method("on_clicked"):
				collider.on_clicked()
				
				# 2. Check if we clicked a move indicator
			elif collider.has_meta("target_square"):
				# Now call AI or wait for input
				var target = collider.get_meta("target_square")
				controller.perform_move(controller.selected_square, target)
				controller.is_player_turn = false # Pass turn to AI
