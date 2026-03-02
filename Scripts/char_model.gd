extends Node3D

var stride_height:float = 1.0
var max_rotation: float = PI/2

var step_time_factor = 0.6
var reset_time:float = 0.01
var velocity:Vector3
enum State {STANDING, WALKING}
var current_state :State = State.STANDING
var skel :Skeleton3D
var is_left_current:bool = true

func _ready() -> void:
	$TorsoTarget/debug.visible = Global.debug_on
	$FootTracker/Holder/LeftFootTrack/Tip/MeshInstance3D.visible = Global.debug_on
	$FootTracker/Holder/RightFootTrack/Tip/MeshInstance3D.visible = Global.debug_on
	skel = find_child("Skeleton3D")
	make_step()
	make_step()
	#path.curve.add_point()

var stride_time:float = 0.01
var step_time:float = 0.01
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
	foot.global_rotation = global_rotation
	foot.rotation.x = -90

var last_look_a:float
var angle_acc:float
var max_turn_before_pivot:float = PI
#calcs angle from current dir to target and sends it to add_rot()
#also calculates accumulated rotation of lower body and resets feet if body rotates too much
func look(target:Vector3, delta:float):
	$TorsoTarget.look_at(target)
	$RHBase.look_at(target)
	var right_x_tilt =$RHBase.rotation.x
	var max_gun_fall:float = PI/4
	$RHBase.rotation.x = clamp(right_x_tilt, -PI/8,PI)
	var target_v: Vector3 = (target-global_position)
	target_v.y = 0
	var upperspine_t :Transform3D = skel.get_bone_global_pose(skel.find_bone("upperspine"))
	#var upperspine_a := (-upperspine_t.basis.z).signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	var a_to_target:float = (-basis.z).signed_angle_to(target_v, Vector3.UP)
	#$RightHandTarget.global_rotation.y = a_to_target
	var rot_y = rotation.y
	angle_acc += rot_y-last_look_a
	if abs(angle_acc) > max_turn_before_pivot:
		_on_changed_dir()
		angle_acc = 0
	#print(angle_acc)
	#if abs(diff) > 0:
		#print("rot {0} last_rot {1} diff {2}".format([a_to_target, last_look_angle, diff]))
	#var rot_speed :float = clamp(a_to_target, -max_rot_speed, max_rot_speed)
	add_rot(a_to_target)
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
#todo change stride time with speed
#todo make stride width constant
#	multiply scale with velocity dir?
#	increase scale.z of foot trackers
#trackers are flipped when moving backwards how to fix
func _process(delta: float) -> void:
	velocity = $"..".velocity
	if velocity.length() > 0.01:
		$Reset.start()
		#rotate tracker vec holder to movement direction independent of look direction
		#flip if rotation relative to movement is less than -pi/2 or greater than pi/2
		var a:= Vector3.FORWARD.signed_angle_to(velocity,Vector3.UP)
		var a_rel := a - rotation.y
		#print(a_rel)
		$FootTracker/Holder.rotation.y = a_rel
		if (a_rel < -PI/2 and a_rel >-3*PI/2) or (a_rel > PI/2 and a_rel < 3*PI/2):
			$FootTracker/Holder.scale.x = -1
		else:
			$FootTracker/Holder.scale.x = 1
	else:
		$Step.stop()

#triggers step for alternating foot
#call directly on beginning to move and also change move direction and also change look direction
#on stopping steps go too far forward
#	recalculate tracker size before making step
func make_step() -> void:
	#print("step")
	if is_left_current:
		move($LeftFoot,$FootTracker/Holder/LeftFootTrack)
	else:
		move($RightFoot,$FootTracker/Holder/RightFootTrack)
	is_left_current = not is_left_current
	$Step.wait_time = step_time
	$Step.start()

func _on_changed_dir():
	make_step()
	pass
