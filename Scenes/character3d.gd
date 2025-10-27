class_name Character3d
extends CharacterBody3D

var speed_start = 1.0
var speed = 2.0
var accel = 0.5
var target:Node3D
var move_dir:Vector2
#keep track of when movement changes direction and emit signal if so
var last_move_dir: Vector2 = Vector2.ZERO
var last_look_angle:float
signal changed_dir
signal changed_look

func _ready():
	connect("changed_dir", $Root._on_changed_dir)
	connect("changed_look", $Root._on_changed_dir)

#self always faces same direction so angles pass from -pi to pi when turning so let model calculate rotation to target
func _physics_process(delta: float) -> void:
	#keep track of change to look angle
	#var a_to_target:float = (-basis.z).signed_angle_to(target.position-position, Vector3.UP)
	#var diff := a_to_target-last_look_angle
	#if abs(diff) > 0:
		#print("rot {0} last_rot {1} diff {2}".format([a_to_target, last_look_angle, diff]))
	#$Root.add_rot(a_to_target-last_look_angle)
	#last_look_angle = a_to_target
	$Root.look(target)
	if abs(last_move_dir.angle_to(move_dir)) >0.1 or (last_move_dir==Vector2.ZERO and move_dir != Vector2.ZERO):
		changed_dir.emit()
		last_move_dir = move_dir
	
	
	var direction := (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	if direction:
		speed = clamp(speed+ accel * delta, speed_start, speed_start*2)
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		
		speed = speed_start
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
