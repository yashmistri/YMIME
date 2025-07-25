extends Sprite2D

var enemy : PackedScene = preload("res://Scenes/enemy.tscn")
var count:=0
signal enemy_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main = get_node("/root/Main")
	connect("enemy_spawned", main._on_enemy_spawned)
	$Pattern.play("pattern1")

func spawn():
	if count <=0:
		return
	
	var e:= enemy.instantiate()
	e.position = global_position
	get_node("/root/Main").call_deferred("add_child", e)
	emit_signal("enemy_spawned")
	count -=1

func add_to_count(amount: int):
	count += amount

func _on_timer_timeout() -> void:
	spawn()
