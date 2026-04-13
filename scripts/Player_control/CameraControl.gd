extends Node3D

@export var cameraPanSpeed: float = 0.0015
@onready var springarm: SpringArm3D = $SpringArm3D
@onready var Camera: Camera3D  = $SpringArm3D/Camera3D
enum CameraStates {ThirdPov, TopDownPOV}
@onready var CameraMode: CameraStates
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#region Input Handler
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * cameraPanSpeed)
		springarm.rotate_x(-event.relative.y * cameraPanSpeed)
		springarm.rotation.x = clamp(springarm.rotation.x, deg_to_rad(-70), deg_to_rad(30))
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		if not event.echo:
			Camera_State()
#endregion

func Camera_State() -> void:
	
	pass
# to do add ability to disable spring arm, and change to top down camera when on mode during match
