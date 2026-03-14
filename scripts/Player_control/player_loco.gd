extends CharacterBody3D

@export var loco_Walk_BlendPath:String;
@export var loco_Run_BlendPath:String;
@export var loco_PlaybackPath:String;
@export var JumpStateName:String;
@export var FallStateName:String;
@export var WalkStateName: String;
@export var animationTree: AnimationTree;
@export var transitionSpeed: float = 0.1;
@export var speed = 5.0
@export var JUMP_VELOCITY = 4.5


var curInput : Vector2;
var curVelocity: Vector2;

var jumpQueue: bool;
var falling: bool;

func Begin_Jump() -> void:
	var playBack = animationTree.get(loco_PlaybackPath) as AnimationNodeStateMachinePlayback;
	playBack.travel(JumpStateName,true);
	pass
func Execute_Jump() -> void:
	velocity.y = JUMP_VELOCITY;
	pass;
	

func _process(delta: float) -> void:
	var newdelta = curInput - curVelocity;
	if (newdelta.length() > transitionSpeed*delta):
		newdelta = newdelta.normalized() * transitionSpeed * delta;
	curVelocity += newdelta;
	animationTree.set(loco_Walk_BlendPath, curVelocity);


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		Begin_Jump();
	pass
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not is_on_floor():
		velocity += get_gravity() * delta;
		jumpQueue = false;
		if !falling:
			falling = true;
			var playback = animationTree.get(loco_PlaybackPath) as AnimationNodeStateMachinePlayback;
			playback.travel(FallStateName)
	else: if falling:
		falling= false;
		var playback = animationTree.get(loco_PlaybackPath) as AnimationNodeStateMachinePlayback;
		playback.travel(WalkStateName);
		
	if jumpQueue:
		velocity.y = JUMP_VELOCITY;
		jumpQueue= false;
		falling = true;
		
	curInput = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(curInput.x, 0, curInput.y)).normalized()
	if direction:
		velocity.x = direction.x * speed 
		velocity.z = direction.z * speed 
	else:
		velocity.x = move_toward(velocity.x, 0, speed )
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
