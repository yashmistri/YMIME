extends CharacterBody2D

@export var speed = 200

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	velocity *= Global.iso_warp_factor

func _physics_process(delta):
	get_input()
	move_and_slide()
