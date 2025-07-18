extends Area2D

var dmg:= 1
var attacker: Character = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Character) -> void:
	print("enter")
	body.take_damage(dmg, attacker)


func _on_area_entered(area: Area2D) -> void:
	#print("dmg'd")
	var ch: Character = area.get_parent()
	ch.take_damage(dmg, attacker)
	set_deferred("monitoring", false)
	visible =false


func _on_activation_timer_timeout() -> void:
	monitoring = true
	visible = true
	$DurationTimer.start()


func _on_duration_timer_timeout() -> void:
	queue_free()
