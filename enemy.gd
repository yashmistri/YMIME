extends CharacterBody2D


const SPEED = 100.0
var nav_agent: NavigationAgent2D

func _ready():
	nav_agent = $NavigationAgent2D

func _physics_process(delta: float) -> void:
	var direction: Vector2
	
	nav_agent.target_position = $"../Player".position
	if not nav_agent.is_navigation_finished():
		direction = nav_agent.get_next_path_position() - position
		direction = direction.normalized()
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	velocity *= Global.iso_warp_factor
	move_and_slide()
