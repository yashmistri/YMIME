extends Character3d
const RAY_LENGTH = 1000

func _ready():
	super._ready()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse1"):
		gun.is_shooting = true
	elif event.is_action_released("mouse1"):
		gun.is_shooting = false
	elif event.is_action_pressed("aim"):
		gun.is_aiming = true
	elif event.is_action_released("aim"):
		gun.is_aiming = false
	elif event.is_action_pressed("sprint"):
		is_sprinting = true
	elif event.is_action_released("sprint"):
		is_sprinting = false
	
func _physics_process(delta):
	move_dir = Input.get_vector("left", "right", "up", "down")
	move_mouse()
	$Flashlight.global_transform = gun.global_transform
	super._physics_process(delta)

func move_mouse():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 0b11

	var result = space_state.intersect_ray(query)
	if result:
		target = result.get("position")
		$Mouse.global_position = target

func die():
	print("Player dead")
