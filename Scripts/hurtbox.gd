extends Area2D
class_name AreaDamage
# todo
# make bool to allow attacking
# check overlapping areas every frame and dmg the first 
# if any then go on cooldown and disable can_attack
#
# option to have areadamage node do damage over time or damage once
# number_of_hits more than zero can damage that many times less than zero unlimited hits
# option to activate instantly or after a time

var dmg:= 1
var attacker: Character = null
var current_target_area: Area2D = null
var can_attack: bool = false
var number_of_hits: int = -1
var tick_cd:= 1.0
var duration_time := 1

#
#func _physics_process(delta: float) -> void:
	#var col_areas: Array[Area2D] = get_overlapping_areas()
	#if(col_areas.size() > 0 and can_attack):
		#print(col_areas[0])
		#damage_char(col_areas[0])

func activate(d, att, num_hits, activate_time, duration_time):
	dmg = d
	attacker = att
	number_of_hits = num_hits
	self.duration_time = duration_time
	$ActivationTimer.start(activate_time)
	#print("activate")

func is_activated():
	return not $ActivationTimer.is_stopped()

func damage_char(area: Area2D) -> void:
	#print("dmg'd")
	if number_of_hits == 0 or !can_attack:
		return
	var ch: Character = area.get_parent()
	ch.take_damage(dmg, attacker)
	if number_of_hits > 0:
		number_of_hits -= 1
	$TickTimer.start(tick_cd)

func _on_activation_timer_timeout() -> void:
	visible = true
	can_attack = true
	if has_node("Explosion"):
		$Explosion.emitting = true
	if duration_time > 0:
		$DurationTimer.start(duration_time)


func _on_duration_timer_timeout() -> void:
	can_attack = false
	#print("duration ended")


func _on_tick_timer_timeout() -> void:
	print(overlaps_area(current_target_area))
	if overlaps_area(current_target_area):
		damage_char(current_target_area)


func _on_area_entered(area: Area2D) -> void:
	#print("area entered")
	#print(area)
	current_target_area = area
	damage_char(area)
