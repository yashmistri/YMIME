extends Node3D

func _ready() -> void:
	$AnimationPlayer.play("one")

func set_val(val:float):
	$Label3D.text = str(val)
