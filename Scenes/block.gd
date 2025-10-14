@tool
extends Sprite2D

const FACE_UP = 0b11
const FACE_DOWN = 0b00
const FACE_RIGHT = 0b01
const FACE_LEFT = 0b10

@export_enum("Left", "Right")
var face_dir := 0



func _draw():
	var t := "DIR"
	match(face_dir):
		0b00:
			t = "D"
		0b01:
			t = "L"
		0b10:
			t = "R"
		0b11:
			t = "U"
	$Dir.visible = Engine.is_editor_hint()
	$Dir.text = t

func _ready():
	#print("face dir left {0} right {1}".format([ face_dir ^0b01, face_dir^0b10]))
	$static/LeftFacingOccluder.visible = face_dir & 0b01
	$static/RightFacingOccluder.visible = face_dir & 0b10
	print("face dir left {0} right {1}".format([ $static/LeftFacingOccluder.visible, $static/RightFacingOccluder.visible]))
	
