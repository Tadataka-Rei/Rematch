extends Node3D


func on_clicked() -> void:
	print("clicked!")


func _on_area_3d_mouse_entered() -> void:
	on_clicked()
	pass
