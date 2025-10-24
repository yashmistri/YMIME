class_name Character3d
extends CharacterBody3D


const SPEED = 5.0
var target:Node3D
var move_dir:Vector2


func _physics_process(delta: float) -> void:
	var model_root :Node3D = $Root
	model_root.look_at(target.position)
	model_root.rotation = Vector3(0, model_root.rotation.y, 0)
	var direction := (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
