extends Control

@export var game_scene: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_new_game_pressed() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		push_error("Game scene has not been assigned in the Inspector!")

func _on_continue_pressed() -> void:
	pass # Replace with function body.

func _on_setting_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	get_tree().quit()
