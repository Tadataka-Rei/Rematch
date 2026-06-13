extends Node3D

enum CameraStates {ThirdPov, TopDownPOV}

@onready var springarm: SpringArm3D = $SpringArm3D
@onready var Camera: Camera3D = $SpringArm3D/Camera3D

@export_category("topdown setting")
@export var topdown_zoom_min: float = 6.0
@export var topdown_zoom_soft_max: float = 18.0
@export var topdown_zoom_max: float = 30.0
@export var topdown_zoom_speed: float = 1.5
@export var topdown_pan_speed: float = 0.015
@export var topdown_pan_limit: float = 10.0
@export var topdown_spin_speed: float = 0.01
@export var topdown_tilt_speed: float = 0.01
@export var topdown_default_height: float = 10.0
@export var topdown_default_zoom: float = 12.0
@export var topdown_default_pitch: float = -0.9599311
@export var topdown_min_pitch: float = -1.3962634
@export var topdown_max_pitch: float = -0.4363323

@export_category("thirdPOV setting")
@export var cameraPanSpeed: float = 0.0015
# ? heh
var controller: Node
var CameraMode: CameraStates = CameraStates.ThirdPov
var topdown_pan_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	controller = get_tree().get_first_node_in_group("controller")
	_apply_third_person_state()

func _input(event: InputEvent) -> void:
	if CameraMode == CameraStates.ThirdPov:
		thirdPOV(event)
	else:
		topdownPov(event)
		select_piece(event)

func thirdPOV(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * cameraPanSpeed)
		springarm.rotate_x(-event.relative.y * cameraPanSpeed)
		springarm.rotation.x = clampf(springarm.rotation.x, deg_to_rad(-70.0), deg_to_rad(30.0))

	if event.is_action_pressed("ui_cancel"):
		_toggle_mouse_mode()

func topdownPov(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_topdown(-topdown_zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_topdown(topdown_zoom_speed)

	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			_pan_topdown(event.relative)
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			if event.alt_pressed:
				_tilt_topdown(event.relative.y)
			else:
				_spin_topdown(event.relative.x)

func _toggle_mouse_mode() -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _zoom_topdown(amount: float) -> void:
	var target_zoom := springarm.spring_length + amount
	if target_zoom > topdown_zoom_soft_max:
		var overshoot := target_zoom - topdown_zoom_soft_max
		target_zoom = topdown_zoom_soft_max + overshoot * 0.35
	springarm.spring_length = clampf(target_zoom, topdown_zoom_min, topdown_zoom_max)

func _pan_topdown(relative: Vector2) -> void:
	var pan_ratio := 1.0
	if springarm.spring_length > topdown_zoom_soft_max:
		pan_ratio += (springarm.spring_length - topdown_zoom_soft_max) / maxf(0.001, topdown_zoom_max - topdown_zoom_soft_max)

	var right_vector := global_basis.x
	right_vector.y = 0.0
	right_vector = right_vector.normalized()

	var forward_vector := -global_basis.z
	forward_vector.y = 0.0
	forward_vector = forward_vector.normalized()

	var pan_delta := (-right_vector * relative.x + forward_vector * relative.y) * topdown_pan_speed * pan_ratio
	topdown_pan_offset.x = clampf(topdown_pan_offset.x + pan_delta.x, -topdown_pan_limit, topdown_pan_limit)
	topdown_pan_offset.y = clampf(topdown_pan_offset.y + pan_delta.z, -topdown_pan_limit, topdown_pan_limit)
	position.x = topdown_pan_offset.x
	position.z = topdown_pan_offset.y

func _spin_topdown(relative_x: float) -> void:
	rotate_y(-relative_x * topdown_spin_speed)

func _tilt_topdown(relative_y: float) -> void:
	springarm.rotate_x(-relative_y * topdown_tilt_speed)
	springarm.rotation.x = clampf(springarm.rotation.x, topdown_min_pitch, topdown_max_pitch)

func Camera_state_toggle() -> void:
	if CameraMode == CameraStates.ThirdPov:
		Change_to_topdown()
	else:
		Change_to_thirdPOV()

func Change_to_topdown() -> void:
	_apply_topdown_state()
	CameraMode = CameraStates.TopDownPOV
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func Change_to_thirdPOV() -> void:
	_apply_third_person_state()
	CameraMode = CameraStates.ThirdPov
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _apply_topdown_state() -> void:
	top_level = false
	Camera.top_level = false
	topdown_pan_offset = Vector2.ZERO
	position = Vector3(0.0, topdown_default_height, 0.0)
	rotation = Vector3.ZERO
	springarm.rotation = Vector3(topdown_default_pitch, 0.0, 0.0)
	springarm.spring_length = topdown_default_zoom

func _apply_third_person_state() -> void:
	top_level = false
	Camera.top_level = false
	topdown_pan_offset = Vector2.ZERO
	position = Vector3.ZERO
	position.y = 1.8
	rotation = Vector3.ZERO
	springarm.rotation = Vector3.ZERO
	springarm.spring_length = 3.0

func select_piece(event) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_length = 1000.0
		var from = Camera.project_ray_origin(mouse_pos)
		var to = from + Camera.project_ray_normal(mouse_pos) * ray_length
		var space = get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = from
		ray_query.to = to
		var result = space.intersect_ray(ray_query)

		if result:
			var collider = result.collider
			if collider.has_method("on_clicked"):
				collider.on_clicked()
			elif collider.has_meta("target_square"):
				var target = collider.get_meta("target_square")
				controller.perform_move(controller.selected_square, target)
				controller.is_player_turn = false
