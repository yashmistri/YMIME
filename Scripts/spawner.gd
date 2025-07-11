extends Sprite2D

var enemy : PackedScene = preload("res://Scenes/enemy.tscn")
var count:=0
var max_count:=10


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn():
	var e:= enemy.instantiate()
	e.position = global_position
	get_node("/root/Main").call_deferred("add_child", e)
	await get_tree().create_timer(2.0).timeout
	if count < max_count:
		spawn()
		count += 1
