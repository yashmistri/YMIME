extends Node2D
class_name Main

@export_category("Cheats")
@export var player_invincible: bool = false
@export var peaceful: bool = false
@export var nomenu:= false
@export_category("misc")
@export var model_y_scale: = 2
var area_dmg: PackedScene = preload("res://Scenes/AreaDamage.tscn")
var enemies_alive := 0
var enemies_defeated_goal := 30
var enemies_defeated := 0
@export var max_enemies_alive := 4
var spawners : Array[Node2D] = []
var enemy : PackedScene = preload("res://Scenes/enemy.tscn")
var enemy_model : PackedScene = preload("res://Scenes/enemy_model.tscn")


func _ready():
	# tiles are not ready during main _ready() despite being descended from Main therefore update tilemaplayer state
	$NavigationRegion2D/Ground.update_internals()
	# set each tile name to location in order to easily find them later
	for child in $NavigationRegion2D/Ground.get_children():
		child.name = "{0}_{1}".format([int(child.position.x), int(child.position.y)])
		if child.is_in_group("Spawner"):
			spawners.append(child)
		#print(child.name)
	$Player.is_invincible = player_invincible
	$Player.model = $SubViewportContainer/SubViewport/PlayerModel
	#await RenderingServer.frame_post_draw
	#var p : Sprite2D = $Player/Camera2D/Proj3D
	#p.texture = $SubViewportContainer/SubViewport.get_texture()
	
	$Darkness.visible = true
	if not nomenu:
		$Player/Camera2D/MainMenu.visible = true
		get_tree().paused = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("fps: " + str(Engine.get_frames_per_second()))
	spawn_enemy()
	$SubViewportContainer/SubViewport/CamHolder.position = $SubViewportContainer/SubViewport/PlayerModel.position
	draw_models()
	#draw_models()
	#var cam2: Node2D = $Player/Camera2D
	#var cam3: Node3D = $SubViewportContainer/SubViewport/Camera3D
	#cam3.position = Vector3(cam2.position.x/(10*Global.iso_warp_factor.x), cam3.position.y, cam2.position.y/(10*Global.iso_warp_factor.y))
	#print("Player pos: {0} Model pos: {1}".format([$Player.position, pmodel.position]))

# draws models to individual sprites for each model
# 
#steps
#in one frame:
# todo
# get list of chars and modify their models and at the same time set the sprite that each model projects to

@export_category("cutout size and offset")
var rect_offset: Vector2 = Vector2(-45,-125)
var rect_size: Vector2 = Vector2(90,150)
func draw_models():
	var vp : SubViewport = $SubViewportContainer/SubViewport
	var cam: Camera3D = $SubViewportContainer/SubViewport/CamHolder/Camera3D
	var cam_frame: Image = vp.get_texture().get_image()
	var c_arr: Array[Node] = get_children()
	
	for c in c_arr:
		if c.is_class("CharacterBody2D"):
			
			var m = c.model
			var sprite :Sprite2D = c.get_node("3DProjection")
			var screen_pos := cam.unproject_position(m.position)
			var char_bb := Rect2(screen_pos+rect_offset, rect_size)
			
			#cam_frame.fill_rect(char_bb, Color.ALICE_BLUE)
			var cutout : Image =cam_frame.get_region(char_bb)
			sprite.texture = ImageTexture.create_from_image(cutout)
			
			#todo find a way to mark all models on viewport not main
			# player 2900 440
			#screen_pos = Vector2(screen_pos.x/(Global.scale3D * Global.iso_warp_factor.x), screen_pos.y/(Global.scale3D * Global.iso_warp_factor.y))
			#print(screen_pos)
	#$Player/Camera2D/Proj3D.texture = ImageTexture.create_from_image(cam_frame)
			
	
	#var capture = vp.get_texture().get_image()
	#var filename = "res://Screenshot-{0}.jpg"
	#capture.save_jpg(filename)
	

# TODO x add model as child of viewport
# x give reference of model to enemy
# have enemy modify position of model
func spawn_enemy():
	if peaceful or enemies_alive >= max_enemies_alive or not $EnemySpawnTimer.is_stopped():
		return
	
	var m:Node3D = enemy_model.instantiate()
	
	var e:Enemy= enemy.instantiate()
	var picked := spawners[randi_range(0,spawners.size()-1)]
	e.position = picked.global_position
	e.level = (enemies_defeated+1)%5
	e.model = m
	call_deferred("add_child", e)
	$SubViewportContainer/SubViewport.call_deferred("add_child", m)
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
	ad.activate(dmg, attacker, 1, 0.5, 0.01)
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
