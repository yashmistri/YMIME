extends Area2D

var dmg:= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Character) -> void:
	print("enter")
	body.take_damage(dmg)


func _on_area_entered(area: Area2D) -> void:
	#print("dmg'd")
	var ch: Character = area.get_parent()
	ch.take_damage(dmg)
