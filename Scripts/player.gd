extends Character
class_name Player

var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
var main: Node2D


func _ready() -> void:
	var hitbox: Area2D = $hitbox
	main = $".."
	hitbox.set_collision_layer_value(1, true)
	
	connect("character_die", $"/root/Main"._on_player_die)
	super._ready()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse1"):
		
		var tile = main.get_clicked_tile(get_global_mouse_position())
		if tile:
			main.spawn_area_dmg(tile, damage)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	velocity *= Global.iso_warp_factor

func _physics_process(delta):
	get_input()
	move_and_slide()
	
func _process(delta):
	$body.target = get_local_mouse_position()
	
func die():
	emit_signal("character_die")
	print("die")
