extends CharacterBody3D

#region --- var stuff ---
@export_group("Animation Paths")
@export var loco_Walk_BlendPath: String = "parameters/locomotion_state_machine/WalkBlend/blend_position"
@export var loco_Run_BlendPath: String = "parameters/locomotion_state_machine/RunBlend/blend_position"
@export var loco_PlaybackPath: String = "parameters/locomotion_state_machine/playback"

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
@export var levitate_height: float = 20.0
@export var levitate_duration: float = 1.5

@onready var armature: Node3D = $Armature
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var playback: AnimationNodeStateMachinePlayback = animationTree.get(loco_PlaybackPath)

@onready var gravity: bool = true
var CanMove: bool = true

var blend_input: Vector2 = Vector2.ZERO
var falling: bool = false
var running: bool = false

var fall_buffer: float = 0.1 # timer prevent flicker go awa-aawawawaw
const FALL_THRESHOLD: float = 0.3
#endregion

# ----------------------------------------bweh---------

func _ready() -> void:
	if (!animationTree):
		set_physics_process(false) # Disable movement if all hell break lose
		push_error("AnimationTree missing!")

func _process(delta: float) -> void:
	var raw_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# genius solution just keep switching back and forth, fuck math, i'm doing meth
	blend_input = blend_input.move_toward(raw_input, transitionSpeed * delta)
	var active_path = loco_Run_BlendPath if running else loco_Walk_BlendPath
	var target_fov = 85.0 if running else 75.0
	
	animationTree.set(active_path, blend_input)
	camera.fov = lerp(camera.fov, target_fov, delta * 5.0)
	
	if (gravity):
		_handle_gravity(delta)

	if (CanMove):
		_handle_movement(raw_input, delta)
	else:
		var target_speed = speed * (1.5 if running else 1.0)
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)
		
	move_and_slide()
	_update_state()

#region  ------------physics & movement----------

# ------------------------- GRAVITY-
func _handle_gravity(delta: float) -> void:
	if (!is_on_floor()):
		velocity += get_gravity() * delta
		
		fall_buffer += delta
		if (!falling && (fall_buffer > FALL_THRESHOLD)):
			falling = true
			playback.travel(FallStateName)
	else:
		fall_buffer = 0.0
		if falling:
			falling = false
			_sync_animation_state()

func _update_state() -> void:
	var move_pressed = Input.is_action_pressed("Shift")
	if (running != move_pressed):
		running = move_pressed
		if is_on_floor():
			_sync_animation_state()

	if (is_on_floor() && Input.is_action_just_pressed("ui_accept")):
		playback.travel(JumpStateName)

func _sync_animation_state() -> void:
	playback.travel(RunStateName if running else WalkStateName)

func _handle_movement(input_dir: Vector2, delta: float) -> void:
	var move_dir = (camera_pivot.global_basis * Vector3(input_dir.x, 0, input_dir.y))
	move_dir.y = 0
	move_dir = move_dir.normalized()
	
	var target_speed = speed * (1.5 if running else 1.0)

	if (move_dir):
		velocity.x = move_dir.x * target_speed
		velocity.z = move_dir.z * target_speed
		
		# Rotate armature brrr
		var target_rotation = atan2(move_dir.x, move_dir.z)
		var current_rot = armature.global_rotation.y
		armature.global_rotation.y = lerp_angle(current_rot, target_rotation, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed)
		velocity.z = move_toward(velocity.z, 0, target_speed)

func Execute_Jump() -> void:
	velocity.y = JUMP_VELOCITY
#endregion

#levy
func levitate_player() -> void:
	Toggle_gravity()
	velocity = Vector3.ZERO # Stop current momentum so it doesn't look janky
	
	var target_y = global_position.y + levitate_height
	var tween = create_tween()
	
	tween.tween_property(self, "global_position:y", target_y, levitate_duration)\
	.set_trans(Tween.TRANS_SINE)\
	.set_ease(Tween.EASE_IN_OUT)

func Toggle_gravity() -> void:
	gravity = !gravity
#endregion

func toggle_cam_state() -> void:
	camera_pivot.Camera_state_toggle()
