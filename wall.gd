extends Sprite2D

# todo have walls fade out if they would block player
# ideas:
# have every wall keep track of player position relative to them and fade out if y distance becomes negative
# every time player steps on a tile hide walls below that tile
# have each wall keep track of player position and go transparent as player approaches a certain point
# start with immediately transparent and later do fade out/in
# have walls be full walls and not blocks if performance is issue
# go translucent if dot product of player relative pos and up is > 0 ?
#	works on single walls but not walls in a line
#	player must be between topleft and topright vectors to hide wall
#	doesnt work try player must be between bottomleft and bottomright vectors to show wall
# or make box area on player that detects walls that would block and signals them to go translucent?
#todo hide sprite not whole node with occluder
#	modulate sprite
#	how to fade walls to translucent
#	as angle approaches the opposite sign pi radians wall should fade out
#maybe fade out should be animation triggered once?
#bug: walls that wouldnt be hiding anything get hidden
#	every wall connecting in a v only fades if all its parts would get faded out
# maybe restrict environment design to not have this problem
#	no v shaped walls?
#	occluder must be only floor tile when hidden
var player: Node2D

func _physics_process(delta: float) -> void:
	if !player: return
	var player_dir := player.global_position - global_position
	var left = Vector2(-2,-1)
	var right = Vector2(2,-1)
	
	# if left angle is neg and right angle is pos then player is below wall
	var left_angle = left.angle_to(player_dir)
	var right_angle = right.angle_to(player_dir)
	#print("left {0} right {1}".format([left_angle,right_angle]))
	#true if wall should be visible
	if (left_angle <0 and right_angle > 0):
		self_modulate = Color(1,1,1,1)
	else:
		self_modulate = Color(1,1,1,0.2)
func set_player(p: Node2D):
	player = p
