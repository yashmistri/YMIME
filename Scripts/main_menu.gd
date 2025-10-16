extends CanvasLayer



func _on_button_pressed() -> void:
	get_tree().paused = false
	visible = false
