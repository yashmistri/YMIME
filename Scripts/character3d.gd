class_name Character3d
extends CharacterBody3D

var speed_start = 1.0
var speed = 3.0
var accel = 0.0
var target:Node3D
var move_dir:Vector2
@export
var max_health: float = 20.0
var current_health: float
var damage:float
#keep track of when movement changes direction and emit signal if so
var last_move_dir: Vector2 = Vector2.ZERO
var last_look_angle:float
signal changed_dir
signal changed_look

func _ready():
	current_health = max_health
	connect("changed_dir", $Root._on_changed_dir)
	connect("changed_look", $Root._on_changed_dir)
	gun = $Root.find_child("Gun")

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
	#print(abs(last_move_dir.angle_to(move_dir)))
	if abs(last_move_dir.angle_to(move_dir)) >=PI or (last_move_dir==Vector2.ZERO and move_dir != Vector2.ZERO) :
		changed_dir.emit()
		last_move_dir = move_dir
	#reset system on stopping but dont make a step
	if last_move_dir != Vector2.ZERO and move_dir == Vector2.ZERO:
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

var gun:Gun
func shoot():
	#print(gun)
	#print("shoot")
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = gun.global_position
	var end = origin + -gun.global_basis.z * gun.range
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 0b11

	var result = space_state.intersect_ray(query)
	if result:
		var c: CollisionObject3D=result.get("collider")
		if c.is_class("CharacterBody3D"):
			c.take_damage(gun.damage)
			#print("cenemy")
		$shot.global_position = result.get("position")
	pass

func take_damage(d:float):
	current_health = clamp(current_health-d, 0.0, max_health)
	print(current_health)
	if current_health ==0.0:
		die()

var is_dead :bool = false
func die():
	print("dead")
	is_dead = true
	var t := get_tree().create_tween()
	t.tween_property()
	queue_free()
