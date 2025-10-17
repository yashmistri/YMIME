extends CharacterBody2D
class_name Character

@export var speed: float = 50
@export var max_health: float = 100
@export var damage:float = 50
var current_health: float
var level: int = 1
var xp: int = 0
var damage_taken: float = 0
var damage_done: float = 0
var is_invincible:= false
var target: Vector2
var model: Node3D

signal character_die

func _ready() -> void:
	
	current_health = max_health
	$HPBar.value = current_health/max_health
	# set viewport texture to sprite to show 3d model
	
	

func _process(delta: float) -> void:
	
	$body.target = target
	model.position = Vector3(position.x/(Global.scale3D * Global.iso_warp_factor.x), model.position.y , position.y/(Global.scale3D * Global.iso_warp_factor.y))
	
	var dir = target-to_local(position)
	model.transform.basis = Basis.IDENTITY
	model.rotate_y(-dir.angle())

func take_damage(damage: float, attacker: Character):
	var applied_dmg =  0 if is_invincible else damage
	current_health = clampf(current_health-applied_dmg, 0,max_health)
	print(name + " took %d" % applied_dmg)
	# counts damage taken past zero
	damage_taken += applied_dmg
	var anim : AnimationPlayer= $Anim
	anim.play("flash_red")
	$HPBar.value = current_health/max_health
	if attacker:
		attacker.damage_done += applied_dmg
	if current_health == 0:
		die()



func give_xp(xp_value: int):
	xp += xp_value
	level = 1 + xp / 4

func die():
	emit_signal("character_die")
	print("die")
	queue_free()
