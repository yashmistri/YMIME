extends Node3D

var damage:float=100.0
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_class("CharacterBody3D"):
		body.take_damage(damage)

func set_col(val:bool):
	$Sword/Area3D.monitoring = val
