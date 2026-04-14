@tool
extends Node3D

var stride_height:float = 1.0
var max_rotation: float = PI/2

var step_time_factor = 0.6
var reset_time:float = 0.01
var is_stopped:bool = true
var velocity:Vector3 = Vector3.ZERO
enum State {STANDING, WALKING}
var current_state :State = State.STANDING
var skel :Skeleton3D
var is_left_current:bool = true
@export var swing_angle_factor:float = 0.0
@export var swing_angle_factor_height:float = 2.0
@export var stride_time:float = 0.01
@export var stride_length:float=1.0
@export var speed:float = 5.0
@export var direction:float = 0.0
@export var step_time:float = 0.01
@export var test_swing: bool = false:
	set(value):
		if value:
			swing()
		test_swing = false 
@export var test_walk: bool = false

func _ready() -> void:
	#$TorsoTarget/debug.visible = Global.debug_on
	$FootTracker/Holder/LeftFootTrack/Tip/shape.visible = Global.debug_on
	$FootTracker/Holder/RightFootTrack/Tip/shape.visible = Global.debug_on
	skel = find_child("Skeleton3D")
	make_step()
	make_step()
	if not Engine.is_editor_hint():
		test_walk = false
	#path.curve.add_point()

func move(foot : Node3D, foot_track : Node3D) -> void:
	#print("move")
	var tracker_vec_tip :Node3D= foot_track.get_node("Tip")
	var final_pos: Vector3
	var final_rot:Vector3
	final_pos = tracker_vec_tip.global_position 
	final_rot = tracker_vec_tip.global_rotation
	#print(velocity.length())
	#if velocity.length() < 0.1:
		#stride_time = stride_time_factor/2.0
	#print(step_time)
	var t =get_tree().create_tween()
	#var rot :Tween = get_tree().create_tween()
	#print(stride_time)
	t.tween_property(foot, "global_position", final_pos, stride_time).set_ease(Tween.EASE_IN)
	#rot.tween_property(foot, "global_rotation", global_rotation, stride_time)
	#foot.global_rotation = global_rotation
	#foot.rotation.x = -90

@export var swing_time:=0.3
var swing_tween:Tween
func swing():
	if swing_tween:
		swing_tween.kill()
	swing_tween = get_tree().create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	var pf:PathFollow3D =find_child("SwingPathFollow")
	pf.progress_ratio=0.1
	
	swing_tween.tween_property(pf,"progress_ratio",1.0,swing_time)
	
	swing_tween.set_trans(Tween.TRANS_LINEAR)
	swing_tween.tween_property(pf,"progress_ratio",0.0,swing_time*1.2).set_delay(0.3)

var last_look_a:float
var angle_acc:float
var max_turn_before_pivot:float = PI/4
#calcs angle from current dir to target and sends it to add_rot()
#also calculates accumulated rotation of lower body and resets feet if body rotates too much
func look(target:Vector3, delta:float):
	$TorsoTarget.look_at(target)
	var model:=$Model
	model.look_at(target)
	$FootTracker/Holder.look_at(target)
	var target_v: Vector3 = (target-global_position)
	target_v.y = 0
	
	var a_to_target:float = (-model.basis.z).signed_angle_to(target_v, Vector3.UP)
	#$RightHandTarget.global_rotation.y = a_to_target
	var rot_y = model.rotation.y
	angle_acc += rot_y-last_look_a
	
	#print(angle_acc)
	if abs(angle_acc) > max_turn_before_pivot:
		_on_changed_dir()
		print("changed dir")
		angle_acc = 0
	#if abs(diff) > 0:
		#print("rot {0} last_rot {1} diff {2}".format([a_to_target, last_look_angle, diff]))
	#var rot_speed :float = clamp(a_to_target, -max_rot_speed, max_rot_speed)
	last_look_a = rot_y

#add rot to upper spine rot unless too much then apply to body rot
#change to set rot and pass rot or target or something
#upperspine rotation is fine but rotating past the limit of upperspine rotation is too slow
#how to reset lower body to match with upperbody
func add_rot(a: float):
	#if ang < 0 : print(ang)
	var max_upperspine_a := 0
	var upperspine_t :Transform3D = skel.get_bone_global_pose(skel.find_bone("upperspine"))
	var upperspine_a := (-upperspine_t.basis.z).signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	#print("a {0} upperspine_a {1}".format([a, upperspine_a]))
	#rotate if within range or if is outside range allow rotation towards center 
	if abs(upperspine_a-a) < max_upperspine_a:
		#if(a > 0.01): print("here")
		upperspine_t.basis = upperspine_t.basis.rotated(Vector3.UP, upperspine_a+a)
		skel.set_bone_global_pose(skel.find_bone("upperspine"), upperspine_t)
	else:
		rotate_y(upperspine_a+a)
	#rotate_y(a)
#how to make a step every time rotate too much
@onready
var swing_target:=$Model/SwingTarget
@onready
var swing_start:=$Model/SwingStart
@onready
var swing_end:=$Model/SwingEnd
@onready
var swing_path:Path3D=$Model/SwingPath
@onready
var swing_center:=$Model/SwingCenter

@onready
var weapon: Node3D = $Model/Armature/Skeleton3D/hand_R/Weapon
func _process(delta: float) -> void:
	if test_walk:
		velocity = speed * Vector3.FORWARD.rotated(Vector3.UP,direction)
	elif not test_walk and Engine.is_editor_hint():
		velocity = Vector3.ZERO
	if Engine.is_editor_hint():
		look($AimTarget.position,delta)
	#rotate rh mesh to match rh target
	#weapon.global_basis = $Model/SwingPath/SwingPathFollow.global_basis
	#print(weapon)
	weapon.look_at(swing_center.position)
	var current_speed:float=velocity.length()
	$LeftFoot.position -= velocity*delta
	$RightFoot.position -= velocity*delta
	$FootTracker/Holder/LeftFootTrack.scale.z = stride_length*current_speed
	$FootTracker/Holder/RightFootTrack.scale.z = stride_length*current_speed
	#set swing start,end, and target points in swing_path node
	var swing_angle_shift = swing_angle_factor * swing_angle_factor_height
	swing_path.curve.set_point_position(0,swing_start.position-Vector3(0,swing_angle_shift,0))
	#swing_path.curve.set_point_position(1,swing_target.position)
	
	swing_path.curve.set_point_position(1,swing_end.position+Vector3(0,swing_angle_shift,0))
	
	
	
	#$FootTracker.position = position
	#how to find up vector of swing? cross of center to target and +x
	#var swing_forward:Vector3 = swing_target.global_position-swing_arc_center.global_position
	#
	#var swing_up:Vector3 = Vector3.RIGHT.cross(swing_forward)
	#swing start = swing_forward rotated around swing_center about swing_up vector
	#print(velocity.length())
	#velocity = $"..".velocity
	if velocity.length() > 0.01:
		var a:= Vector3.FORWARD.signed_angle_to(velocity,Vector3.UP)
		$FootTracker/Holder/LeftFootTrack.global_rotation.y = a
		$FootTracker/Holder/RightFootTrack.global_rotation.y = a
		is_stopped = false
		if $Step.is_stopped():
			make_step()
			#print('stop, step')
		#wait before resetting both feet to standing position
		$Reset.start()
		$Reset2.start()
		
		#rotate tracker vec holder to movement direction independent of look direction
		#flip if rotation relative to movement is less than -pi/2 or greater than pi/2
		
		#if (a_rel < -PI/2 and a_rel >-3*PI/2) or (a_rel > PI/2 and a_rel < 3*PI/2):
			#$FootTracker/Holder.scale.x = -1
		#else:
			#$FootTracker/Holder.scale.x = 1
	else:
		is_stopped = true
		0

#triggers step for alternating foot
#call directly on beginning to move and also change move direction and also change look direction
#on stopping steps go too far forward
#	recalculate tracker size before making step
func make_step() -> void:
	if Engine.is_editor_hint() and not test_walk:
		return
	#print("step")
	if is_left_current:
		move($LeftFoot,$FootTracker/Holder/LeftFootTrack)
	else:
		move($RightFoot,$FootTracker/Holder/RightFootTrack)
	is_left_current = not is_left_current
	if not is_stopped:
		#print("restart timer")
		$Step.start(step_time)


func _on_changed_dir():
	make_step()
	pass
