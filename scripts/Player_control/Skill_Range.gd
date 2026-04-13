extends Area3D

@onready var Skill_pivot = get_tree().get_first_node_in_group("Skill_Pivot")

func _ready() -> void:
	self.body_entered.connect(_on_area_3d_body_entered)
	self.body_exited.connect(_on_area_3d_body_exited)
	if Skill_pivot:
		print("Found Skill_Pivot!")
		Skill_pivot.set_process_input(false)
	else:
		print("Error: Skill_Pivot node not found in group!")

#region --------AREA3d----------------
func _on_area_3d_body_entered(body: Node3D) -> void:
	if (body.is_in_group("Monolith")):
		Skill_pivot.set_process_input(true)
		Skill_pivot.target_enemy = body;
	pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
	if (body.is_in_group("Monolith")):
		Skill_pivot.target_enemy = null;
		Skill_pivot.set_process_input(false)
	pass # Replace with function body.
	

#endregion
