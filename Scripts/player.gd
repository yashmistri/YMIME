extends Character
class_name Player

var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
var main: Node2D
var ability1_charges := 0
var ability1_damage_scaling := 0.2
var ability1_max_charges := 3
var ability1_recharge_time := 2.0


func _ready() -> void:
	ability1_charges = ability1_max_charges
	var hitbox: Area2D = $hitbox
	var anim: AnimationPlayer = $LightAnim
	anim.play("LightBreathe")
	main = $".."
	hitbox.set_collision_layer_value(1, true)
	connect("character_die", $"/root/Main"._on_player_die)
	super._ready()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse1"):
		
		var tile = main.get_clicked_tile(get_global_mouse_position())
		if tile:
			ability1(tile)

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

func ability1(t: Node2D):
	if ability1_charges == 0:
		return
	var success: bool = main.spawn_area_dmg(t, damage * ability1_damage_scaling + 5*level, self)
	if success:
		ability1_charges -= 1
		$A1Recharge.start()

func _on_a_1_recharge_timeout() -> void:
	ability1_charges += 1
	#print("charges: {0}".format([ability1_charges]))
	if ability1_charges < ability1_max_charges:
		$A1Recharge.start()
