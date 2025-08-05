extends Node2D
class_name Main

var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
var enemies_alive := 0
var enemies_defeated_goal := 10
var enemies_defeated := 0

func _ready():
	# tiles are not ready during main _ready() despite being descended from Main therefore update tilemaplayer state
	$NavigationRegion2D/Ground.update_internals()
	# set each tile name to location in order to easily find them later
	for child in $NavigationRegion2D/Ground.get_children():
		child.name = "{0}_{1}".format([int(child.position.x), int(child.position.y)])
		#print(child.name)
	
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_area_dmg(tile: Node2D, dmg: float, attacker: Character):
	if !tile:
		return
	if !tile.has_node("AreaDamage"):
		return
	tile.get_node("AreaDamage").activate(dmg, attacker)
	

func get_clicked_tile(pos: Vector2):
	var tile_map_layer := $NavigationRegion2D/Ground
	var clicked_cell = tile_map_layer.local_to_map(to_local(pos))
	
	#tile_map_layer.erase_cell(clicked_cell)
	var data = get_tile_node(tile_map_layer, clicked_cell)
	#print(data)
	if data:
		return data
	else:
		return null

func get_tile_node(tile_map_layer: TileMapLayer, child_coord: Vector2i) -> Node2D:
	var local_coords := tile_map_layer.map_to_local(child_coord)
	var coords = "{0}_{1}".format([int(local_coords.x), int(local_coords.y)])
	return tile_map_layer.get_node(coords)
	
func _on_enemy_spawned():
	enemies_alive += 1
	#print("enemies alive: " + str(enemies_alive))
	
func _on_enemy_die():
	enemies_defeated += 1
	enemies_alive -= 1
	if enemies_defeated >= enemies_defeated_goal:
		end_game(true)

func _on_player_die():
	end_game(false)

func end_game(is_win: bool):
	if is_win:
		print("win")
	else:
		print("lose")
	get_tree().paused = true
	$Player/Camera2D/GameOverLayer.visible = true
	
	$Player/Camera2D/GameOverLayer/GameOverPanel/HBoxContainer/Stats/dmgDone.text = "Damage Done: {0}".format([$Player.damage_done])
	$Player/Camera2D/GameOverLayer/GameOverPanel/HBoxContainer/Stats/dmgTaken.text = "Damage Taken: {0}".format([$Player.damage_taken])
	$Player/Camera2D/GameOverLayer/GameOverPanel/HBoxContainer/Stats/enemiesDestroyed.text = "Enemies Defeated: {0}".format([enemies_defeated])
