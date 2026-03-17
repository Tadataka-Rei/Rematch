extends CharacterBody3D

@export_group("Paths")
@export var loco_Walk_BlendPath: String
@export var loco_Run_BlendPath: String
@export var loco_PlaybackPath: String
@export var JumpStateName: String
@export var FallStateName: String
@export var WalkStateName: String
@export var RunStateName: String

@export_group("Settings")
@export var animationTree: AnimationTree
@export var transitionSpeed: float = 8.0
@export var speed: float = 5.0
@export var rotation_speed: float = 10.0
@export var JUMP_VELOCITY: float = 4.5

@onready var armature: Node3D = $Armature
@onready var camera_pivot: Node3D = $CameraPivot

var curVelocity: Vector2 = Vector2.ZERO
var falling: bool = false
var running: bool = false

func _ready() -> void:
	if not animationTree:
		push_error("AnimationTree not assigned!")

func get_playback() -> AnimationNodeStateMachinePlayback:
	return animationTree.get(loco_PlaybackPath)

# Triggered by Animation Call Method Track
func Execute_Jump() -> void:
	velocity.y = JUMP_VELOCITY

func _process(delta: float) -> void:
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	curVelocity = curVelocity.move_toward(input_dir, transitionSpeed * delta)
	
	if !running:
		animationTree.set(loco_Walk_BlendPath, curVelocity)
	else:
		animationTree.set(loco_Run_BlendPath, curVelocity)

func _physics_process(delta: float) -> void:
	# Gravity Logic
	if not is_on_floor():
		velocity += get_gravity() * delta
		if not falling:
			falling = true
			get_playback().travel(FallStateName)
	else:
		if falling:
			falling = false
			get_playback().travel(RunStateName if running else WalkStateName)

	running = Input.is_action_pressed("Shift")
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		get_playback().travel(JumpStateName)

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Don't ask me how this work, I copy it from youtube tutorial
	var dir = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_pivot.rotation.y)
	
	var current_speed = speed * 1.5 if running else speed

	if dir.length() > 0.001:
		velocity.x = dir.x * current_speed
		velocity.z = dir.z * current_speed
		
		# ROTATE THE AMATURE
		var target_angle = atan2(-dir.x, -dir.z)
		armature.rotation.y = lerp_angle(armature.rotation.y, target_angle, rotation_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
