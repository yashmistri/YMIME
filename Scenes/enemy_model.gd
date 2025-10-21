extends Node3D

var current_tween: Tween
@export
var max_stride_length :float = 0.5
var stride_length:float = 0.4
var stride_height:float = 1.0
var max_rotation: float = PI/2
var stride_time:float = 0.3
@export
var curve:Curve3D
var path:Path3D
var path_follow:PathFollow3D

#todo make curve and make it parabola and make foot naturally rise and lower when moving
#make lower torso move up and down and rotate naturally
#make upper torso rotate to look at mouse
#make hands move with procedural anim like feet while hands are empty
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
func move(foot : Node3D, foot_track : Node3D) -> void:
	var vec: Vector3 = foot_track.global_position - foot.global_position
	var d :float = vec.length()
	var r :float = foot.global_basis.x.angle_to(foot_track.global_basis.x)
	var move_foot:bool = false # if foot needs to move
	var final_transform:Transform3D
	if d > max_stride_length or r > max_rotation:
		# length of this will be huge at start therefore keep to standard length
		final_transform = Transform3D(foot_track.global_basis, foot_track.global_position + vec.limit_length(stride_length))
		move_foot = true
	if move_foot and not current_tween.is_valid():
		
		current_tween =get_tree().create_tween()
		current_tween.tween_property(foot, "global_transform", final_transform, stride_time).set_ease(Tween.EASE_IN_OUT)
		
		current_tween.tween_callback(current_tween.kill)

func _process(delta: float) -> void:
	move($RightFoot,$RightFootTrack)
	move($LeftFoot,$LeftFootTrack)
	#
	#var skel :Skeleton3D = $robot/Armature/Skeleton3D
	#var skel_final_pos :Transform3D = skel.global_transform * skel.get_bone_global_pose(skel.find_bone("footIK.L"))
	#skel_final_pos = $LeftFoot.global_transform
	#skel.set_bone_global_pose(skel.find_bone("footIK.L"),skel.global_transform.affine_inverse() * skel_final_pos)
