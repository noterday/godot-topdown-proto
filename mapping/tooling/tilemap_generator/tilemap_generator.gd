@tool
## A tilemap group which automatically generates a 2.5 shape from a top-down view.
extends PerspectiveTileMapLayerGroup


## The number of layers to generate
const total_layers := 8


## Sets the alpha value of the child nodes in the editor to more easily work.
@export_range(0, 1, 0.01) var editor_visibility : float = 1:
	set(value):
		editor_visibility = value
		update_editor_visbility()
@export var layer_tileset : TileSet


# Reference to the tile data to signal any tilemap changes while in editor
@onready var previous_tile_data : PackedByteArray = PackedByteArray([])


## Generates the child tilemap layers when added to a scene
func _enter_tree() -> void:
	_create_internal_layer_nodes()
	# Benchmark Start
	var start
	var end
	start = Time.get_ticks_usec()
	generate_floors()
	end = Time.get_ticks_usec()
	print((end-start) / 16666.7) # Get function time in frames (60fps)
	# Benchmark End
	update_editor_visbility()


## In Editor, Checks each frame for a map update and regenerate the layers
func _process(_delta : float) -> void:
	super(_delta)
	if Engine.is_editor_hint():
		if previous_tile_data != tile_map_data:
			previous_tile_data = tile_map_data
			generate_floors()


## While in the editor, updates the visibility of child layers.
func update_editor_visbility() -> void:
	if Engine.is_editor_hint():
		for child in get_children(true):
			if child is Node2D:
				child.modulate.a = editor_visibility


## Generates 2.5D floor according to the template drawn on this group layer.
# TODO: Fairly flow to run, needs optimization
func generate_floors() -> void:
	var cells : Array[Vector2i]
	var layer : PerspectiveTileMapLayer
	# Normal Floor generation
	for i in range(total_layers-1, -1, -1):
		layer = get_child(i, true)
		layer.clear()
		# SLOW : Array merging bellow increases function cost by 10x
		cells = get_used_cells_by_id(0, Vector2i(i, 0)) + cells
		layer.set_cells_terrain_connect(cells, 0, 0)


## Creates a set of internal PerspectiveTileMapLayer nodes that will be drawn to.
func _create_internal_layer_nodes() -> void:
	var layer : PerspectiveTileMapLayer
	for child in get_children(true):
		if child.get_meta("is_internal_tilemap_layer") == true:
			child.queue_free()
	for i in range(total_layers):
		layer = PerspectiveTileMapLayer.new_with_tileset(layer_tileset)
		layer.tile_set = layer_tileset
		layer.set_meta("is_internal_tilemap_layer", true)
		add_child(layer, false, Node.INTERNAL_MODE_FRONT)
