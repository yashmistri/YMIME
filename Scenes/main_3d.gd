extends Node3D


func _process(delta: float) -> void:
	var hpbar:TextureProgressBar = find_child("HP")
	var enbar:TextureProgressBar = find_child("Energy")
	
	hpbar.value = $Player.current_health/$Player.max_health
	enbar.value = $Player.current_energy/$Player.max_energy
