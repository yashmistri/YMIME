extends Node3D

var current_tween: Tween
@export
var max_stride_length :float = 1.2
var stride_length:float = 1.1
var stride_height:float = 1.0
var max_rotation: float = PI/2
var stride_time:float = 0.1
var reset_time:float = 0.01
var velocity:Vector3
@export
var curve:Curve3D
var path:Path3D
var path_follow:PathFollow3D
enum State {STANDING, WALKING}
var current_state :State = State.STANDING

#todo make curve and make it parabola and make foot naturally rise and lower when moving
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
	# tween is not null
	current_tween = get_tree().create_tween()
	current_tween.kill()
	$robot/Armature/Skeleton3D/LeftIK.start()
	$robot/Armature/Skeleton3D/RightIK.start()
	
	#path.curve.add_point()

# set top_level but it goes to 0,0
# save global position then set toplevel then set position to that
# doesnt work
# regular foot move algo should take care of it

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
#change tracker vector based on state
func move(foot : Node3D, foot_track : Node3D) -> void:
	var tracker_vec_origin = foot_track.get_node("Holder/Origin")
	var tracker_vec_tip = foot_track.get_node("Holder/Tip")
	var foot_vec: Vector3 = foot.global_position - tracker_vec_origin.global_position
	var tracker_vec: Vector3 = tracker_vec_tip.global_position - tracker_vec_origin.global_position
	var d :float = foot_vec.dot(tracker_vec)
	var r :float = foot.global_basis.x.angle_to(foot_track.global_basis.x)
	var move_foot:bool = false # if foot needs to move
	var final_pos: Vector3
	if d < 0:
		final_pos = tracker_vec_tip.global_position 
		move_foot = true
	if move_foot and not current_tween.is_valid():
		
		current_tween =get_tree().create_tween()
		current_tween.tween_property(foot, "global_position", final_pos, stride_time).set_ease(Tween.EASE_IN_OUT)
		
		current_tween.tween_callback(current_tween.kill)

#how to lean torso forwards and to the side of lead foot when foot is far forward
#how to get lead foot:
#	get 2d vector of feet releative to self forward
#	lead foot is max dot product
#get basis of torso to lead foot
func move_torso():
	var r_local_pos :Vector3= $RightFoot.global_position - global_position
	var l_local_pos :Vector3= $LeftFoot.global_position - global_position
	print("right {0} left {1}".format([r_local_pos, l_local_pos]))
	if(r_local_pos.z < l_local_pos.z):
		pass
	
	#dist between feet
	#feet dist range is {0.2,2.2}
	var d: float = r_local_pos.distance_to(l_local_pos)
	#print(d)
	var default_y:= 0.0
	var shift_range:= 0.5
	var shift_amount := remap(d, 0.2, 2.2, default_y, default_y-shift_range)
	$robot.position.y = shift_amount


#todo change stride time with speed
func _process(delta: float) -> void:
	velocity = $"..".velocity
	#keep restarting until stop moving, then let timer finish
	if velocity.length() > 0.1:
		$Reset.start()
		#rotate tracker vec holder to movement direction independent of look direction
		$RightFootTrack/Holder.rotation.y = Vector3.FORWARD.signed_angle_to(velocity,Vector3.UP) - rotation.y
		$LeftFootTrack/Holder.rotation.y = Vector3.FORWARD.signed_angle_to(velocity,Vector3.UP) - rotation.y
	else:
		$RightFootTrack/Holder.rotation.y = 0
		$LeftFootTrack/Holder.rotation.y = 0
	
	move($RightFoot,$RightFootTrack)
	move($LeftFoot,$LeftFootTrack)
	move_torso()

func _on_reset_timeout() -> void:
	print("reset")
