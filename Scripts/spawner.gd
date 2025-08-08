extends Sprite2D

var count:=0
signal enemy_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main = get_node("/root/Main")
	connect("enemy_spawned", main._on_enemy_spawned)
	$Pattern.play("pattern1")



func add_to_count(amount: int):
	count += amount
