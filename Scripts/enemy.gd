extends Character
class_name Enemy

var nav_agent: NavigationAgent2D

func _ready():
	nav_agent = $NavigationAgent2D
	var hitbox: Area2D = $hitbox
	hitbox.set_collision_layer_value(2, true)
	set_collision_layer_value(2, true)
	$hurtbox.dmg = damage
	$hurtbox.attacker = self
	connect("character_die", $"/root/Main"._on_enemy_die)
	
	super._ready()

func _physics_process(delta: float) -> void:
	var direction: Vector2
	var player := $"../Player"
	if player != null:
		nav_agent.target_position = player.position
		$body.target = to_local(player.position)
	if not nav_agent.is_navigation_finished():
		direction = nav_agent.get_next_path_position() - position
		direction = direction.normalized()
	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	velocity *= Global.iso_warp_factor
	move_and_slide()
