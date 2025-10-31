class_name Gun
extends Node3D

@export_category("gun stats")
@export var range :float = 100.0
@export var damage:float = 10.0
@export var rps:float = 1.0
@export var mag_size:int = 10
@export var reload_time:float = 2.0
@export var is_auto:bool = true
var can_shoot:bool=true

func shoot():
	if not can_shoot:
		return
	#print(gun)
	print("shoot")
	var space_state = get_world_3d().direct_space_state

	var origin = global_position
	var end = origin + -global_basis.z * range
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	query.collision_mask = 0b11

	var result = space_state.intersect_ray(query)
	if result:
		var c: CollisionObject3D=result.get("collider")
		if c.is_class("CharacterBody3D"):
			c.take_damage(damage)
			#print("cenemy")
		
	can_shoot = false
	var fd :float= 1.0/rps
	$FireDelay.start(fd)
	
	return result.get("position")


func _on_fire_delay_timeout() -> void:
	can_shoot = true
	if is_auto:
		shoot()
