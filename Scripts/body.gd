extends Node2D

var target: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = target
	var mouse_dir = mouse_pos-position
	$arm_holder/wand.rotation = mouse_dir.angle()
