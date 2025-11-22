extends Character3d


var nav_agent: NavigationAgent3D
var can_follow:bool = true
var can_shoot:bool = true
var burst_amount:int = 10
var burst_delay_time:float = 2.0
var shots_fired:int = 0
func _ready():
	
	nav_agent = $NavigationAgent3D
	#$Root.make_step()
	super._ready()

#todo if reached player wait before following to avoid stutter
# actually wait until player leaves maximum follow distance
func _physics_process(delta: float) -> void:
	var player :Character3d= $"../Player"
	
	var direction := nav_agent.get_next_path_position() - position
	#less points in path -> more likely a straight line to player
	var player_visible:bool = nav_agent.get_current_navigation_path().size()<5
	#enemy burst fires then waits
	#check if current mag has mod burst bullets but not max bullets and doesnt get stuck at this value
	#print(nav_agent.get_current_navigation_path().size())
	if shots_fired==burst_amount:
		can_shoot=false
		shots_fired=0
		$BurstDelay.start(burst_delay_time)
	#print(nav_agent.distance_to_target())
	if player != null:
		var max_target_find_speed:=0.03
		target = lerp(target, player.position, max_target_find_speed)
		#target.x = move_toward(target.x, player.position.x, max_target_find_speed*delta)
		#target.z = move_toward(target.z, player.position.z, max_target_find_speed*delta)
		var target_error:float = target.distance_to(player.position)
		#print(d_to_target)
		if player_visible and target_error < 1.0 and nav_agent.distance_to_target() < 4.0 and can_shoot:
			gun.is_shooting = true
		elif nav_agent.distance_to_target()>6.0:
			gun.is_shooting = false
		nav_agent.target_position = target
	if not nav_agent.is_navigation_finished():
		#print(nav_agent.distance_to_target())
		if can_follow and not gun.is_shooting:
			move_dir = Vector2(direction.x, direction.z).normalized()
		else:
			move_dir = Vector2.ZERO
	else:
		move_dir = Vector2.ZERO
		$FollowDelay.start()
		can_follow=false
		
	
	super._physics_process(delta)


func _on_follow_delay_timeout() -> void:
	can_follow=true


func _on_burst_delay_timeout() -> void:
	can_shoot=true


func _on_gun_has_fired() -> void:
	shots_fired +=1

func die():
	start_ragdoll()
	is_dead = true
