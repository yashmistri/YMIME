extends CanvasLayer

func _ready() -> void:
	visible = false

func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
