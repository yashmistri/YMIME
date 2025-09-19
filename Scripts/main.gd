extends Node2D
class_name Main

var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
var enemies_alive := 0
var enemies_defeated_goal := 30
var enemies_defeated := 0
var max_enemies_alive := 10
var spawners : Array[Node2D] = []
var enemy : PackedScene = preload("res://Scenes/enemy.tscn")


func _ready():
	# tiles are not ready during main _ready() despite being descended from Main therefore update tilemaplayer state
	$NavigationRegion2D/Ground.update_internals()
	# set each tile name to location in order to easily find them later
	for child in $NavigationRegion2D/Ground.get_children():
		child.name = "{0}_{1}".format([int(child.position.x), int(child.position.y)])
		if child.is_in_group("Spawner"):
			spawners.append(child)
		#print(child.name)
	
	get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_enemy()
	

func spawn_enemy():
	if enemies_alive >= max_enemies_alive or not $EnemySpawnTimer.is_stopped():
		return
	var e:= enemy.instantiate()
	var picked := spawners[randi_range(0,spawners.size()-1)]
	e.position = picked.global_position
	call_deferred("add_child", e)
	enemies_alive += 1
	$EnemySpawnTimer.start()

func spawn_area_dmg(tile: Node2D, dmg: float, attacker: Character) -> bool:
	if !tile:
		return false
	if !tile.has_node("AreaDamage"):
		return false
	if tile.get_node("AreaDamage").is_activated():
		return false
	var ad : AreaDamage = tile.get_node("AreaDamage")
	ad.set_collision_mask_value(3, true)
	ad.activate(dmg, attacker, 1, 0.5, -1)
	spawn_text("EXPLOSION", tile.global_position)
	return true

func spawn_text(str: String, pos: Vector2):
	var text := load("res://Scenes/FloatingText.tscn")
	var instance :FloatingText = text.instantiate()
	instance.set_text(str)
	instance.position = pos
	call_deferred("add_child", instance)
	

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
	$Player.give_xp(1)
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


func _on_enemy_spawn_timer_timeout() -> void:
	
	spawn_enemy()
