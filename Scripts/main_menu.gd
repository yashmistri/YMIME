extends CanvasLayer


func _ready() -> void:
	visible = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	visible = false
