extends Node2D
class_name Main

var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
func _ready():
	# tiles are not ready during main _ready() despite being descended from Main therefore update tilemaplayer state
	$NavigationRegion2D/Ground.update_internals()
	# set each tile name to location in order to easily find them later
	for child in $NavigationRegion2D/Ground.get_children():
		child.name = "{0}_{1}".format([int(child.position.x), int(child.position.y)])
		#print(child.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_area_dmg(pos: Vector2):
	var a := area_dmg.instantiate()
	a.position = pos
	call_deferred("add_child", a)
	

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
