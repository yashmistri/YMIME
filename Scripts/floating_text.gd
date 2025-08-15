extends Node2D
class_name FloatingText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Anim.play("float")

func set_text(str: String):
	$Node2D/Text.text = str
