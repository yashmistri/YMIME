extends Node3D

#multiplies with speed to set track vector scale which is stride length
var stride_length_factor:float = 1.8
var stride_height:float = 1.0
var max_rotation: float = PI/2
#divides by speed and controls stride time; more =slower stride same for step time
var stride_time_factor:float = 0.4
var step_time_factor = 0.6

var reset_time:float = 0.01
var velocity:Vector3
@export
var curve:Curve3D
var path:Path3D
var path_follow:PathFollow3D
enum State {STANDING, WALKING}
var current_state :State = State.STANDING
var skel :Skeleton3D
var is_left_current:bool = true

#todo make curve and make it parabola and make foot naturally rise and lower when moving
#steps are much faster when standing still but dont trigger every change of direction
#make lower torso move up and down and rotate naturally
#	torso height is inv proportional to distance between feet
#	make torso lean forward and to lead foot while walking
#	torso leans more at higher move speed
#make upper torso rotate to look at mouse
#make hands move with procedural anim like feet while hands are empty
#how to smoother steps:
#	? max stride length starts short, then long on first step, then remains long until foot returns to center then becomes short again
# 	quickly reset feet to middle  after not moving for a moment or when turning
# 	one foot moves immediately on moving after reset
#	how to get velocity/direction of movement?
#reset motion:
#	timer starts after reaching zero velocity or (zero move input?) and resets on moving
#	if timer reaches end call reset function which starts a tween that moves feet to start
#	and makes max stride length really small for the first step only
#use states? standing and walking
# if on slope set foot position to slope and rotation to slope normal
func _ready() -> void:
	
	for c in find_children("", "SkeletonIK3D"):
		c.start()
	skel = find_child("Skeleton3D")
	make_step()
	make_step()
	#path.curve.add_point()

#foot algo
#if rotation or distance is too much since last move, reset to foot_track
# bug: both feet can move at the same time 
# sol: dont move foot to start but some distance past the tracker
#		have to make first movement of feet instant or fade in scene slowly
# or simply only one foot moves at a time
# 	only activate one foot tween if other is inactive
#	one foot gets stuck if other is in endless loop
#how to give foot movement natural parabola
#	instead of tween whole transform tween x,z,basis normally and tween y with parabola
#	not possible so make path between start and end and tween that for position
#walking state:
#	tracker vector changes based on movement vector
#	distance foot travels before triggering move also changes
#		get vector from vector base to foot and tracker vector
#		move if dot product is negative
#		vector changes with both move direction and rotation
#		use dot product to determine when foot drags too far
#		display debug vector first before implementing rest of function
#		start with circle for vector orientations then do ellipse
#		
#	forward: 
#rotate holder with move direction

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

#how to lean torso forwards and to the side of lead foot when foot is far forward
#how to get lead foot:
#	get 2d vector of feet releative to self forward
#	lead foot is max dot product
#make IK for head and upper torso and set target here
#torso target should move with pelvis height; remove top level?
#how to get tween progress; tween time elapse divided by stride time
#set tempo of torso movement in proportion to tween progress
@export
var lean_height:float = 1.9
@export
var lean_side_factor:float = 0.1
func move_torso():
	var torso_target:Node3D = $TorsoTarget
	var lean_forward:float
	var step_progress:float = 0
	step_progress = clamp(step_progress, 0.0,1.0)
	var r :Vector3= $RightFoot.global_position - global_position
	var l :Vector3= $LeftFoot.global_position - global_position
	r.y = 0
	l.y = 0
	r = r.normalized()
	l = l.normalized()
	var forward :Vector3 = -global_basis.z
	var r_dot := r.dot(forward)
	var l_dot := l.dot(forward)
	var lean_factor :float= max(r_dot, l_dot)
	lean_forward = clamp(remap(lean_factor, 0.5,1.0,0.3,0.7),0.3,1.0)
	var lean_side = remap(r_dot-l_dot, -2,2, -lean_side_factor, lean_side_factor)
	torso_target.position = Vector3(lean_side,lean_height,-lean_forward)

	#print("right {0} left {1} forward {2}".format([r_dot, l_dot, forward]))
	
	#dist between feet
	#feet dist range is {0.2,2.2}
	var d: float = $RightFoot.global_position.distance_to($LeftFoot.global_position)
	#print(d)
	var default_y:= -0.1
	var shift_range:= 0.3
	var shift_amount := remap(d, 0.2, 2.2, default_y, default_y-shift_range)
	$robot.position.y = shift_amount

var last_look_a:float
var angle_acc:float
var max_turn_before_pivot:float = PI
#calcs angle from current dir to target and sends it to add_rot()
#also calculates accumulated rotation of lower body and resets feet if body rotates too much
func look(target:Node3D):
	$TorsoTarget.look_at(target.global_position)
	$RightHandTarget.look_at(target.global_position)
	var target_v: Vector3 = (target.global_position-global_position)
	target_v.y = 0
	var upperspine_t :Transform3D = skel.get_bone_global_pose(skel.find_bone("upperspine"))
	#var upperspine_a := (-upperspine_t.basis.z).signed_angle_to(Vector3.FORWARD, Vector3.UP)
	
	var a_to_target:float = (-basis.z).signed_angle_to(target_v, Vector3.UP)
	var rot_y = rotation.y
	angle_acc += rot_y-last_look_a
	if abs(angle_acc) > max_turn_before_pivot:
		_on_changed_dir()
		angle_acc = 0
	#print(angle_acc)
	#if abs(diff) > 0:
		#print("rot {0} last_rot {1} diff {2}".format([a_to_target, last_look_angle, diff]))
	add_rot(a_to_target)
	last_look_a = rot_y

#add rot to upper spine rot unless too much then apply to body rot
#change to set rot and pass rot or target or something
#upperspine rotation is fine but rotating past the limit of upperspine rotation is too slow
func add_rot(a: float):
	#if ang < 0 : print(ang)
	var max_upperspine_a := PI/4
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
	#print(stride_length_factor*velocity.length())
	#sets position of feet end position after move
	#todo make min ho distance between feet
	var stride_factor:float = clamp(stride_length_factor*velocity.length(), 0.1,3.0 )
	$FootTracker/Holder/LeftFootTrack.scale.z = stride_factor
	$FootTracker/Holder/RightFootTrack.scale.z =stride_factor
	#keep restarting until stop moving, then let timer finish
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
	
	if velocity.length() > 0.1:
		#print(step_time_factor / (velocity.length()+0.00001))
		step_time = clamp(step_time_factor / (velocity.length()+0.0001), 0.01, 4.0)
		stride_time = clamp(stride_time_factor/(velocity.length()+0.0001), 0.01, 4.0)
		#print(step_time)
	else:
		#step_time = step_time_factor/2.0
		0
		#move one foot immediately
		#make_step()
	move_torso()

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
	#print("changeddir")
	stride_time = 0.2
	step_time=0.1
	make_step()
	pass
