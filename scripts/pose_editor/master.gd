extends Node2D

var mdt = MeshDataTool.new()

# Player meshes
@onready var player_wide = $player_full
@onready var player_slim = $player_slim
@onready var items = $HBoxContainer/LeftContainer/items
@onready var selected_item
@onready var skin_image = $HBoxContainer/RightContainer/skin_image

var steve_texture = preload("res://assets/models/steve.png")
var alex_texture = preload("res://assets/models/alex.png")

#sliders
@onready var bend_slider = $HBoxContainer/LeftContainer/GridContainer/bend
@onready var x_slider = $HBoxContainer/LeftContainer/GridContainer/x
@onready var y_slider = $HBoxContainer/LeftContainer/GridContainer/y
@onready var z_slider = $HBoxContainer/LeftContainer/GridContainer/z
@onready var pickup_changes = false

enum TypeSelected {WIDE, SLIM}
var type_selected = TypeSelected.WIDE

# Body parts
@onready var player_mesh = {
	TypeSelected.WIDE : {
		"Head" : {
			"base" : player_wide.get_node("Node/Head/"),
			"underlay": player_wide.get_node("Node/Head/Head_001"),
			"overlay": player_wide.get_node("Node/Head/Hat Layer")
		},
		"Right Arm" : {
			"base" : player_wide.get_node("Node/RightArm/"),
			"underlay": player_wide.get_node("Node/RightArm/Right Arm"),
			"overlay": player_wide.get_node("Node/RightArm/Right Arm Layer")
		},
		"Left Arm" : {
			"base" : player_wide.get_node("Node/LeftArm/"),
			"underlay": player_wide.get_node("Node/LeftArm/Left Arm"),
			"overlay": player_wide.get_node("Node/LeftArm/Left Arm Layer")
		},
		"Body" : {
			"base" : player_wide.get_node("Node"),
			"underlay": player_wide.get_node("Node/Body/Body_001"),
			"overlay": player_wide.get_node("Node/Body/Body Layer")
		},
		"Right Leg" : {
			"base" : player_wide.get_node("Node/RightLeg/"),
			"underlay": player_wide.get_node("Node/RightLeg/Right Leg"),
			"overlay": player_wide.get_node("Node/RightLeg/Right Leg Layer")
		},
		"Left Leg" : {
			"base" : player_wide.get_node("Node/LeftLeg/"),
			"underlay": player_wide.get_node("Node/LeftLeg/Left Leg"),
			"overlay": player_wide.get_node("Node/LeftLeg/Left Leg Layer")
		}
	},
	TypeSelected.SLIM : {
		"Head" : {
			"base" : player_slim.get_node("Node/Head/"),
			"underlay": player_slim.get_node("Node/Head/Head_001"),
			"overlay": player_slim.get_node("Node/Head/Hat Layer")
		},
		"Right Arm" : {
			"base" : player_slim.get_node("Node/RightArm/"),
			"underlay": player_slim.get_node("Node/RightArm/Right Arm"),
			"overlay": player_slim.get_node("Node/RightArm/Right Arm Layer")
		},
		"Left Arm" : {
			"base" : player_slim.get_node("Node/LeftArm/"),
			"underlay": player_slim.get_node("Node/LeftArm/Left Arm"),
			"overlay": player_slim.get_node("Node/LeftArm/Left Arm Layer")
		},
		"Body" : {
			"base" : player_slim.get_node("Node"),
			"underlay": player_slim.get_node("Node/Body/Body_001"),
			"overlay": player_slim.get_node("Node/Body/Body Layer")
		},
		"Right Leg" : {
			"base" : player_slim.get_node("Node/RightLeg/"),
			"underlay": player_slim.get_node("Node/RightLeg/Right Leg"),
			"overlay": player_slim.get_node("Node/RightLeg/Right Leg Layer")
		},
		"Left Leg" : {
			"base" : player_slim.get_node("Node/LeftLeg/"),
			"underlay": player_slim.get_node("Node/LeftLeg/Left Leg"),
			"overlay": player_slim.get_node("Node/LeftLeg/Left Leg Layer")
		}
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	type_selected = TypeSelected.WIDE
	for key in player_mesh[type_selected]:
		items.add_item(key)
	_apply_skin(steve_texture, player_mesh[TypeSelected.WIDE])
	_apply_skin(alex_texture, player_mesh[TypeSelected.SLIM])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_x_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.x = value

func _on_y_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.y = value
	
func _on_z_value_changed(value):
	if not pickup_changes:
		return
	selected_item.base.rotation_degrees.z = value

func _on_bend_value_changed(value):
	if not pickup_changes:
		return
	selected_item.underlay.bend(value)
	selected_item.overlay.bend(value)

func _on_items_item_selected(index):
	pickup_changes = false
	bend_slider.visible = true
	
	selected_item = player_mesh[type_selected][items.get_item_text(index)]
	x_slider.value = selected_item.base.rotation_degrees.x
	y_slider.value = selected_item.base.rotation_degrees.y
	z_slider.value = selected_item.base.rotation_degrees.z
	
	if selected_item.underlay is PlayerLimb:
		bend_slider.value = selected_item.underlay.get_current_bend()
	else:
		bend_slider.visible = false
	pickup_changes = true
	
func _apply_skin(skin_texture, parts_dict):
	skin_image.texture = skin_texture
	for key in parts_dict:
		for segment in parts_dict[key]:
			var m = parts_dict[key][segment]
			if m is MeshInstance3D:
				mdt.create_from_surface(m.mesh, 0)
				var skin_material = mdt.get_material()
				skin_material.albedo_texture = skin_texture
				#skin_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
				mdt.set_material(skin_material)
				m.mesh.clear_surfaces()
				mdt.commit_to_surface(m.mesh)

func _on_file_dialog_file_selected(path):
	var texture = ImageTexture.new()
	var image = Image.new()
	image.load(path)
	texture.set_image(image)
	_apply_skin(texture, player_mesh[type_selected])
	
func _carry_info(from_mesh: TypeSelected, to_mesh: TypeSelected):
	var parts_dict = player_mesh[from_mesh]
	for key in parts_dict:
		if parts_dict[key] == selected_item:
			selected_item = player_mesh[to_mesh][key]
		for segment in parts_dict[key]:
			var from_segment = player_mesh[from_mesh][key][segment]
			var to_segment = player_mesh[to_mesh][key][segment]
			to_segment.rotation_degrees.x = from_segment.rotation_degrees.x
			to_segment.rotation_degrees.y = from_segment.rotation_degrees.y
			to_segment.rotation_degrees.z = from_segment.rotation_degrees.z
			if to_segment is PlayerLimb: 
				to_segment.bend(from_segment.get_current_bend())
		


func _on_skintype_item_selected(index):
	if index == 0:
		player_slim.visible = false
		player_wide.visible = true
		type_selected = TypeSelected.WIDE
		_carry_info(TypeSelected.SLIM, TypeSelected.WIDE)
	if index == 1:
		player_wide.visible = false
		player_slim.visible = true
		type_selected = TypeSelected.SLIM
		_carry_info(TypeSelected.WIDE, TypeSelected.SLIM)