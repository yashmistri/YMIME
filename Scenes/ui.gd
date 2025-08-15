extends CanvasLayer

func _process(delta: float) -> void:
	var player:Character = $"../.."
	$Panel/HBoxContainer/HealthLabel.text = "HP: {0}/{1}".format([player.current_health, player.max_health])
	$Panel/HBoxContainer/Charges.text = "Charges: {0}/{1}".format([player.ability1_charges, player.ability1_max_charges])
	$Panel/HBoxContainer/Level.text = "Player Level: {0}".format([player.level])
