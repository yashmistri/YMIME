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

signal character_die

func _ready() -> void:
	
	current_health = max_health
	$HPBar.value = current_health/max_health

func take_damage(damage: float, attacker: Character):
	current_health = clampf(current_health-damage, 0,max_health)
	print(name + " took %d" % damage)
	# counts damage taken past zero
	damage_taken += damage
	var anim : AnimationPlayer= $Anim
	anim.play("flash_red")
	$HPBar.value = current_health/max_health
	if attacker:
		attacker.damage_done += damage
	if current_health == 0:
		die()



func give_xp(xp_value: int):
	xp += xp_value
	level = 1 + xp / 4

func die():
	emit_signal("character_die")
	print("die")
	queue_free()
