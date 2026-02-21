class_name Character3d
extends CharacterBody3D

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
@export
var max_health: float = 50.0
var current_health: float
var damage:float
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

var gun:Gun
func _ready():
	current_health = max_health
	current_energy = max_energy
	accel = accel_stat
	connect("changed_dir", $Root._on_changed_dir)
	connect("changed_look", $Root._on_changed_dir)
	gun = find_child("Gun")
	stop_ragdoll()

# tween bonesim influence 0 to 1 and ik influence 1 to 0?
func start_ragdoll():
	$Collision.disabled = true
	is_ragdoll = true
	#$Root.visible = false
	#$Ragdoll.visible = true
	
	
	set_ragdoll_pose()
	#get_tree().paused = true
	#bs.influence = 0.0
	#var bt :Tween = get_tree().create_tween()
	#bt.tween_property(bs,"influence",1.0,2.0)

#figure out how to get correct bone poses in real time 
func stop_ragdoll():
	$Collision.disabled = false
	is_ragdoll = false
	$Root.start_IK()
	$Root.visible = true
	#$Ragdoll.visible = false
	var bs : PhysicalBoneSimulator3D = $Root.find_child("BoneSim")
	bs.active = false
	bs.physical_bones_stop_simulation()

#start with setting ragdoll right leg pos to real model right leg
#keep IKs active during ragdoll?
#apply poses to physicalbones not reg bones?
func set_ragdoll_pose():
	# how to find all bone poses and 
	#store bone poses by index
	var skel:Skeleton3D = $Root.find_child("Skeleton3D")
	#var ragdoll_skel:Skeleton3D = $Ragdoll.find_child("Skeleton3D")
	var bone_poses: Array[Transform3D]
	
	for bone_idx in range(skel.get_bone_count()):
		var t :Transform3D = Transform3D(skel.global_transform*skel.get_bone_global_pose(bone_idx))
		bone_poses.append(t)
		
		print("bone {0} idx {1} pose {2}".format(["bone_name",bone_idx,bone_poses[bone_idx]]))
	#$Root.stop_IK()
	var bs : PhysicalBoneSimulator3D = $Root.find_child("BoneSim")
	bs.physical_bones_start_simulation()
	bs.active = true
	for bone_idx in range(skel.get_bone_count()):
		skel.set_bone_global_pose_override(bone_idx,bone_poses[bone_idx],1.0)
	return
	#await get_tree().process_frame
	#await get_tree().create_timer(0.1).timeout
	for bone:PhysicalBone3D in bs.get_children():
		#var bone_name = "lowerleg.R"
		#var bone_idx = skel.find_bone(bone_name)
		#print(bone.bone_name)
		var bone_idx = skel.find_bone(bone.bone_name)
		print(bone_idx)
		bone.joint_offset = bone_poses[bone_idx]
		#var bone_global_t:Transform3D = global_transform*skel.get_bone_global_pose(bone_idx)
		#skel.set_bone_global_pose(bone_idx,bone_poses[bone_idx])
		#print("bone {0} idx {1} pose {2}".format([bone_name,bone_idx,skel.get_bone_global_pose(bone_idx)]))

#self always faces same direction so angles pass from -pi to pi when turning so let model calculate rotation to target
func _physics_process(delta: float) -> void:
	#set_ragdoll_pose()
	if is_ragdoll or is_dead:
		return
	if gun.is_shooting:
		var p=  gun.shoot()
		if p and has_node("shot"):
			$shot.global_position = p
	
	
	$Flashlight.global_transform = gun.get_node("Tip").global_transform
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
	#print(abs(last_move_dir.angle_to(move_dir)))
	if abs(last_move_dir.angle_to(move_dir)) >=PI or (last_move_dir==Vector2.ZERO and move_dir != Vector2.ZERO) :
		changed_dir.emit()
		last_move_dir = move_dir
	#reset system on stopping but dont make a step
	if last_move_dir != Vector2.ZERO and move_dir == Vector2.ZERO:
		last_move_dir = move_dir
	
	if current_energy ==0.0:
		is_exhausted=true
	if current_energy > 20.0 and is_exhausted:
		is_exhausted = false
	
	var direction := (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	if direction:
		if is_sprinting and current_energy > 0.0 and not gun.is_shooting and not is_exhausted:
			current_energy = move_toward(current_energy, 0.0, sprint_energy_rate*delta)
			
			speed = move_toward(speed, speed_start*2, accel*delta)
		else:
			speed = move_toward(speed, speed_start, accel*delta*1.5)
			
		if gun.is_shooting or gun.is_aiming:
			speed *= 1.0
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		speed = speed_start
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	if (direction and not is_sprinting) or not direction:
		current_energy = move_toward(current_energy, max_energy, sprint_energy_rate*delta)

	
	move_and_slide()



func take_damage(d:float):
	current_health = clamp(current_health-d, 0.0, max_health)
	#print(current_health)
	if current_health ==0.0:
		die()

func die():
	print("dead")
	is_dead = true
	#var t := get_tree().create_tween()
	#t.tween_property()
	queue_free()
