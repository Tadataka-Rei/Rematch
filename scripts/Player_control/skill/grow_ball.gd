extends MeshInstance3D

@export var target_scale: Vector3 = Vector3(5, 5, 5)
@export var duration: float = 0.6

var _initial_scale: Vector3

func _ready():
	_initial_scale = scale
	visible = false

## grows ball
func ball():
	visible = true
	top_level = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", target_scale, duration)

## shrink ball, be balless
func orchiectomy():
	top_level = false
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", _initial_scale, duration)
	
	tween.finished.connect(func(): visible = false)
