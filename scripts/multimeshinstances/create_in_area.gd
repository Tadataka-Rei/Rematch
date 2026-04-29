extends MultiMeshInstance3D

@export var cube_count := 200
@export var area_size := 100.0
@export var min_height := 1.0
@export var max_height := 10.0

func _ready():
	multimesh.instance_count = cube_count
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in cube_count:
		var x = rng.randf_range(-area_size, area_size)
		var z = rng.randf_range(-area_size, area_size)
		var y = rng.randf_range(min_height, max_height)
		
		transform.origin = Vector3(x, y, z)
		multimesh.set_instance_transform(i, transform)
