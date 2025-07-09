extends CharacterBody2D
class_name Character

@export var speed = 50
@export var max_health: float = 100
@export var damage = 50
var current_health: float

func _ready() -> void:
	
	pass

func take_damage(damage: float):
	current_health = clampf(current_health-damage, 0,max_health)
	print(name + " took %d" % damage)
	if current_health == 0:
		die()

func die():
	print("die")
