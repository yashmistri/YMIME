extends Character3d
const RAY_LENGTH = 1000

func _ready():
	
	target = $Mouse

func _physics_process(delta):
	move_dir = Input.get_vector("left", "right", "up", "down")
	move_mouse()
	super._physics_process(delta)

func move_mouse():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 0b10

	var result = space_state.intersect_ray(query)
	if result:
		$Mouse.global_position = result.get("position")
