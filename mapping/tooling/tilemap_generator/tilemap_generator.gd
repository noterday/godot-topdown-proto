@tool
## A tilemap group which automatically generates a 2.5 shape from a top-down view.
extends PerspectiveTileMapLayerGroup


# The number of layers to generate
const _total_layers := 8


## Forces the map to be redrawn on the spot and sets itself to false again
@export var force_redraw : bool:
	set(value):
		force_redraw = false
		if Engine.is_editor_hint() and is_node_ready():
			generate_map()


## The tileset that will be used for map generation.
## [br][br]This tileset must have two atlases :
## [br]1. Atlas 1 is a floor tileset. It has a terrain setup in terrain set 0.
## [br]2. Atlas 2 is the wall tileset. It has the same size as Atlas 1.
## [br][br]Special cases can be defined for tiles which are ambiguous
## and do not properly draw in the bottom corners of walls. Custom data layers named 
## "TilingLeftMatch", "TilingRightMatch", and "TilingBothMatch" must be defined
## which store Vector2i references to appropriate handpicked tile coordinates.
@export var layer_tileset : TileSet:
	set(value):
		layer_tileset = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_map()


## This value is used for the floor at the bottom layer of the map.
@export var bottom_floor : Vector2i = Vector2i(9, 2):
	set(value):
		bottom_floor = value
		if Engine.is_editor_hint() and is_node_ready():
			generate_map()


# Editor use only. Reference to the tile data to signal any tilemap changes.
@onready var previous_tile_data : PackedByteArray = PackedByteArray([])


## Generates the child tilemap layers when added to a scene
func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		generate_map()
	else: # Debug
		self_modulate.a = 0


## In Editor, Checks each frame for a map update and regenerate the layers
func _process(delta : float) -> void:
	super(delta)
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
	var tile_data : TileData
	var left_neighbor : bool
	var right_neighbor : bool
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
	if layer_tileset.get_source_count() < 2:
		return
	for i in range(_total_layers):
		layer = get_child(i)
		cells = wall_cells_per_layer[i]
		for cell in cells:
			floor_atlas_coord = layer.get_cell_atlas_coords(cell)
			if floor_atlas_coord != Vector2i(-1, -1):
				# The wall tile must use the same atlas coord as the floor tile it should be above
				layer.set_cell(cell, 1, floor_atlas_coord, 0)
				# But some special case are needed for the edges of floor level walls
				# These are fixed using hand picked values using the custom data bellow
				if _has_custom_tile_match_data():
					left_neighbor = (cell + Vector2i.LEFT not in cells)
					right_neighbor = (cell + Vector2i.RIGHT not in cells)
					tile_data = layer_tileset.get_source(1).get_tile_data(floor_atlas_coord, 0)
					if left_neighbor and tile_data.get_custom_data("LeftTilingMatch"):
						layer.set_cell(cell, 1, tile_data.get_custom_data("LeftTilingMatch"), 0)
						if right_neighbor and tile_data.get_custom_data("BothTilingMatch"):
							layer.set_cell(cell, 1, tile_data.get_custom_data("BothTilingMatch"), 0)
					elif right_neighbor and tile_data.get_custom_data("RightTilingMatch"):
						layer.set_cell(cell, 1, tile_data.get_custom_data("RightTilingMatch"), 0)


## Checks if the needed custom data is present to fix edge cases with wall tiles
func _has_custom_tile_match_data() -> bool:
	var needed_names = ["LeftTilingMatch", "RightTilingMatch", "BothTilingMatch"]
	for i in range(layer_tileset.get_custom_data_layers_count()):
		if layer_tileset.get_custom_data_layer_name(i) in needed_names:
			needed_names.erase(layer_tileset.get_custom_data_layer_name(i))
	return needed_names.is_empty()


## Creates a set of internal PerspectiveTileMapLayer nodes that will be drawn to.
func _initialize_layer_nodes() -> void:
	var layer : PerspectiveTileMapLayer
	var counter := 0
	for child in get_children():
		if child.get_meta("is_internal_tilemap_layer") == true:
			counter += 1
	for i in range(_total_layers - counter):
		layer = PerspectiveTileMapLayer.new_with_tileset(layer_tileset)
		add_child(layer)
		layer.set_meta("is_internal_tilemap_layer", true)
		layer.name = "Layer " + str(i)
		layer.owner = get_tree().edited_scene_root
