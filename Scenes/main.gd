extends Node2D



func _ready():
	for child in $NavigationRegion2D/Ground:
		child.name = 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mouse1"):
		
		var tile = get_clicked_tile()
		if tile:
			print("click")

func get_clicked_tile():
	var tile_map_layer := $NavigationRegion2D/Ground
	var clicked_cell = tile_map_layer.local_to_map(tile_map_layer.get_local_mouse_position())
	
	#tile_map_layer.erase_cell(clicked_cell)
	print(clicked_cell)
	var data = tile_map_layer.get_cell_alternative_tile(clicked_cell)
	print(data)
	if data:
		return data
	else:
		return null

func get_tile_node(tile_map_layer: TileMapLayer, child_coord: Vector2i):
	var source_id = tile_map_layer.get_cell_source_id(child_coord)
	print(source_id)
	return null
	var scene : Node2D = null
	if source_id > -1:
		var scene_source = tile_map_layer.tile_set.get_source(source_id)
		if scene_source is TileSetScenesCollectionSource:
			var alt_id = tile_map_layer.get_cell_alternative_tile(child_coord)
			# The assigned PackedScene.
			scene = scene_source.get_scene_tile_scene(alt_id)
	return scene
