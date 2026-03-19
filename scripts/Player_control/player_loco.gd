extends CharacterBody3D

# --- var stuff ---
@export_group("Animation Paths")
@export var loco_Walk_BlendPath: String = "parameters/Walk/blend_position"
@export var loco_Run_BlendPath: String = "parameters/Run/blend_position"
@export var loco_PlaybackPath: String = "parameters/playback"

@export_group("State Names")
@export var JumpStateName: String = "Jump"
@export var FallStateName: String = "Fall"
@export var WalkStateName: String = "Walk"
@export var RunStateName: String = "Run"

@export_group("Movement Settings")
@export var animationTree: AnimationTree
@export var transitionSpeed: float = 0.3
@export var speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var JUMP_VELOCITY: float = 4.5

@onready var armature: Node3D = $Armature
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var playback: AnimationNodeStateMachinePlayback = animationTree.get(loco_PlaybackPath)

var blend_input: Vector2 = Vector2.ZERO
var falling: bool = false
var running: bool = false

var fall_buffer: float = 0.0 # timer prevent flicker
const FALL_THRESHOLD: float = 0.3
# ----------------------------------------bweh---------

func _ready() -> void:
	if not animationTree:
		set_physics_process(false) # Disable movement if all hell break lose
		push_error("AnimationTree missing!")

#region visuals & FOV
func _process(delta: float) -> void:
	var raw_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var target_blend = Vector2(raw_input.x, -raw_input.y)
	
	blend_input = blend_input.move_toward(target_blend, transitionSpeed * delta)


	var active_path = loco_Run_BlendPath if running else loco_Walk_BlendPath
	var target_fov = 85.0 if running else 75.0
	
	animationTree.set(active_path, blend_input)
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0)
#endregion

#region physics & movement
func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_movement(delta)
	move_and_slide()
	
	# State check AFTER movement to ensure accurate is_on_floor()
	_update_state()

func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		fall_buffer += delta
		if not falling and fall_buffer > FALL_THRESHOLD:
			falling = true
			playback.travel(FallStateName)
	else:
		fall_buffer = 0.0
		if falling:
			falling = false
			_sync_animation_state()

func _update_state() -> void:
	var move_pressed = Input.is_action_pressed("Shift")
	if running != move_pressed:
		running = move_pressed
		if is_on_floor():
			_sync_animation_state()

	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		playback.travel(JumpStateName)

func _sync_animation_state() -> void:
	playback.travel(RunStateName if running else WalkStateName)

func _handle_movement(delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	var move_dir = (camera_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	move_dir.y = 0
	move_dir = move_dir.normalized()
	
	var target_speed = speed * (1.5 if running else 1.0)

	if move_dir:
		velocity.x = move_dir.x * target_speed
		velocity.z = move_dir.z * target_speed
		
		# Rotate armature 
		var target_rotation = atan2(move_dir.x, move_dir.z)
		armature.rotation.y = lerp_angle(armature.rotation.y, target_rotation, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)

func Execute_Jump() -> void:
	velocity.y = JUMP_VELOCITY
#endregion
