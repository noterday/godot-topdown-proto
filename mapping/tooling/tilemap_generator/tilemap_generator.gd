@tool
## A tilemap group which automatically generates a 2.5 shape from a top-down view.
extends PerspectiveTileMapLayerGroup


# The number of layers to generate
const _total_layers := 8


## Forces the map to be redrawn on the spot and sets itself to false again
@export var force_redraw : bool:
	set(value):
		force_redraw = false
		if Engine.is_editor_hint():
			generate_map()


## The tileset that will be used for map generation.
## [br]This tileset must have two atlases :
## [br]1. Atlas 1 is a floor tileset. It has a terrain setup in terrain set 0.
## [br]2. Atlas 2 is the wall tileset. It has the same size as Atlas 1.
@export var layer_tileset : TileSet:
	set(value):
		layer_tileset = value
		if Engine.is_editor_hint():
			generate_map()


## This value is used for the floor at the bottom layer of the map.
@export var bottom_floor : Vector2i = Vector2i(9, 2):
	set(value):
		bottom_floor = value
		if Engine.is_editor_hint():
			generate_map()


# Editor use only. Reference to the tile data to signal any tilemap changes.
@onready var previous_tile_data : PackedByteArray = PackedByteArray([])


## Generates the child tilemap layers when added to a scene
func _ready() -> void:
	if Engine.is_editor_hint():
		generate_map()
	else: # Debug
		self_modulate.a = 0


## In Editor, Checks each frame for a map update and regenerate the layers
func _process(_delta : float) -> void:
	super(_delta)
	if Engine.is_editor_hint():
		if previous_tile_data != tile_map_data:
			previous_tile_data = tile_map_data
			_initialize_layer_nodes()
			generate_map()
	

## Generates 2.5D floor according to the template drawn on this group layer.
func generate_map() -> void:
	var cells : Array[Vector2i]
	var wall_cells_per_layer : Array[Array]
	var layer : PerspectiveTileMapLayer
	var floor_atlas_coord : Vector2i
	_initialize_layer_nodes()
	cells = []
	# Set floor tiles
	for i in range(_total_layers-1, -1, -1):
		layer = get_child(i)
		layer.clear()
		wall_cells_per_layer.push_front(cells)
		cells = get_used_cells_by_id(0, Vector2i(i, 0))  + cells
		if i == bottom:
			for cell in cells:
				layer.set_cell(cell, 0, bottom_floor, 0)
		else:
			layer.set_cells_terrain_connect(cells, 0, 0)
	# Set wall tiles
	if layer_tileset.get_source_count() > 1:
		for i in range(_total_layers):
			cells = wall_cells_per_layer[i]
			for cell in cells:
				layer = get_child(i)
				floor_atlas_coord = layer.get_cell_atlas_coords(cell)
				if floor_atlas_coord != Vector2i(-1, -1):
					layer.set_cell(cell, 1, floor_atlas_coord, 0)


## Creates a set of internal PerspectiveTileMapLayer nodes that will be drawn to.
func _initialize_layer_nodes() -> void:
	var layer : PerspectiveTileMapLayer
	var counter := 0
	for child in get_children():
		if child.get_meta("is_internal_tilemap_layer") == true:
			counter += 1
	for i in range(_total_layers - counter):
		layer = PerspectiveTileMapLayer.new_with_tileset(layer_tileset)
		layer.set_meta("is_internal_tilemap_layer", true)
		add_child(layer)
		layer.owner = get_tree().edited_scene_root
