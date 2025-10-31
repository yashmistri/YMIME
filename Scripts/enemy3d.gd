extends Character3d


var nav_agent: NavigationAgent3D
var can_follow:bool = true

func _ready():
	
	nav_agent = $NavigationAgent3D
	#$Root.make_step()
	super._ready()

#todo if reached player wait before following to avoid stutter
# actually wait until player leaves maximum follow distance
func _physics_process(delta: float) -> void:
	var player :Character3d= $"../Player"
	if player != null:
		nav_agent.target_position = player.position
		target = player
	if not nav_agent.is_navigation_finished():
		#print(nav_agent.distance_to_target())
		var direction := nav_agent.get_next_path_position() - position
		if can_follow:
			move_dir = Vector2(direction.x, direction.z).normalized()
	else:
		move_dir = Vector2.ZERO
		$FollowDelay.start()
		can_follow=false
		
	
	super._physics_process(delta)


func _on_follow_delay_timeout() -> void:
	can_follow=true
