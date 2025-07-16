extends Sprite2D

var enemy : PackedScene = preload("res://Scenes/enemy.tscn")
var count:=0
var max_count:=10
signal enemy_spawned

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main = get_node("/root/Main")
	main.total_enemies += max_count
	connect("enemy_spawned", main._on_enemy_spawned)
	
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn():
	var e:= enemy.instantiate()
	e.position = global_position
	get_node("/root/Main").call_deferred("add_child", e)
	emit_signal("enemy_spawned")
	
	await get_tree().create_timer(2.0).timeout
	if count < max_count:
		spawn()
		count += 1
