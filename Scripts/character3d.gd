class_name Character3d
extends CharacterBody3D
@export
var speed_start = 1.0
var speed = 1.0
var accel = 0.0
var accel_stat = 1.0
var current_energy:float
var max_energy:float = 200.0
#per second
var sprint_energy_rate:float = 30.0
var energy_replete_rate:float = 10.0
var target:Vector3
var move_dir:Vector2
var is_dashing:bool=false
@export
var max_health: float = 50.0
var current_health: float
@export
var damage:float=10.0
#keep track of when movement changes direction and emit signal if so
var last_move_dir: Vector2 = Vector2.ZERO
var last_look_angle:float
var is_sprinting:bool=false
#true when energy reaches 0 and back to false when energy replenishes to threshold
var is_exhausted:bool = false
var is_ragdoll:bool = false
var is_dead :bool = false
signal changed_dir
signal changed_look

func _ready():
	current_health = max_health
	current_energy = max_energy
	accel = accel_stat
	speed = speed_start
	var weapon:=find_child("Weapon")
	#print("weapon")
	weapon.damage = damage
	connect("changed_dir", $Root._on_changed_dir)
	connect("changed_look", $Root._on_changed_dir)
	

func dash():
	speed = speed_start*2.0
	$DashTimer.start()

func reset_speed():
	speed=speed_start
#self always faces same direction so angles pass from -pi to pi when turning so let model calculate rotation to target
func _physics_process(delta: float) -> void:
	#set_ragdoll_pose()
	if is_ragdoll or is_dead:
		return
	
	
		#accel = 0.0
		#speed = speed_start
	#print(current_energy)
	#keep track of change to look angle
	#var a_to_target:float = (-basis.z).signed_angle_to(target.position-position, Vector3.UP)
	#var diff := a_to_target-last_look_angle
	#if abs(diff) > 0:
		#print("rot {0} last_rot {1} diff {2}".format([a_to_target, last_look_angle, diff]))
	#$Root.add_rot(a_to_target-last_look_angle)
	#last_look_angle = a_to_target
	$Root.look(target, delta)
	#$Root.velocity = velocity
	#print(abs(last_move_dir.angle_to(move_dir)))
	if abs(last_move_dir.angle_to(move_dir)) >=PI or (last_move_dir==Vector2.ZERO and move_dir != Vector2.ZERO) :
		print("changed input dir")
		changed_dir.emit()
		last_move_dir = move_dir
	#reset system on stopping but dont make a step
	if last_move_dir != Vector2.ZERO and move_dir == Vector2.ZERO:
		last_move_dir = move_dir
	
	var direction := (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		speed = speed_start
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
	
	#print(velocity.length())



func take_damage(d:float):
	current_health = clamp(current_health-d, 0.0, max_health)
	spawn_damage_text(d)
	$anim.play("shake")
	print(current_health)
	if current_health ==0.0:
		die()

func spawn_damage_text(dmg:float):
	var d:=preload("res://Scenes/damage_text.tscn").instantiate()
	d.set_val(dmg)
	get_tree().root.add_child(d)
	d.global_position = global_position
	d.position.y+=1

func die():
	print("dead")
	is_dead = true
	#var t := get_tree().create_tween()
	#t.tween_property()
	queue_free()
