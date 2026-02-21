extends Control

func _ready() -> void:
	$Anim.play("slide")

func _process(delta: float) -> void:
	var t1 =$SubViewport/T1
	var t2 =$SubViewport/T1/T2
	var t3 =$SubViewport/T1/T3
	
	t2.text = t1.text
	t3.text = t1.text
