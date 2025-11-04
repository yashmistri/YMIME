class_name Gun
extends Node3D

@export_category("gun stats")
@export var gun_range :float = 100.0
@export var damage:float = 10.0
@export var rps:float = 5.0
@export var mag_size:int = 200
@export var reload_time:float = 2.0
@export var aim_speed:float = 1.0
@export var is_auto:bool = true
var can_shoot:bool=true
@export var min_spread:float = 0.05
@export var max_spread:float = 0.3
var spread:float
var is_shooting:bool = false
var is_aiming:bool = false
var current_mag: int
var bullet_scene:PackedScene
var target_pos: Vector3

func _ready():
	current_mag = mag_size
	bullet_scene = load("res://Scenes/bullet.tscn")
	spread = max_spread

func _process(delta: float) -> void:
	var aim_delta :float = delta/aim_speed
	if is_aiming:
		spread = move_toward(spread, min_spread, aim_delta)
	else:
		spread = move_toward(spread, max_spread, aim_delta*2)
	#print(spread)

func shoot():
	if not can_shoot:
		return
	#print(gun)
	#print("shoot")
	
	var space_state = get_world_3d().direct_space_state
	var dir :Vector3 = -global_basis.z * gun_range
	dir = dir.rotated(Vector3.UP, randf_range(-spread, spread))
	var origin = global_position
	var end = origin + dir
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 0b11

	var result = space_state.intersect_ray(query)
	if result:
		var c: CollisionObject3D=result.get("collider")
		target_pos = result.get("position")
		if c.is_class("CharacterBody3D"):
			c.take_damage(damage)
			#print("cenemy")
	current_mag -= 1
	if current_mag == 0:
		$Reload.start(reload_time)
		is_shooting = false
	else:
		var fd :float= 1.0/rps
		$FireDelay.start(fd)
	can_shoot = false
	spawn_bullet()
	return result.get("position")

func spawn_bullet():
	var b:Node3D= bullet_scene.instantiate()
	b.position = global_position
	b.look_at_from_position(global_position, target_pos)
	#print(target_pos)
	var t = get_tree().create_tween()
	t.tween_property(b, "position", target_pos, 0.1)
	t.tween_callback(b.queue_free)
	add_child(b)

func _on_fire_delay_timeout() -> void:
	can_shoot = true
	if is_auto and is_shooting:
		shoot()


func _on_reload_timeout() -> void:
	can_shoot = true
	current_mag = mag_size
	spread = max_spread
	#print("reload")
