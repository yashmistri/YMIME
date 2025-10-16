extends Node2D

var target: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos = target
	var dir = pos-position
	$arm_holder/wand.rotation = dir.angle()
