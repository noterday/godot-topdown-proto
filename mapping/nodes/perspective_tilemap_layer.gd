@tool
## A tilemap layer made to exist in the 3/4 view perspective of the game.
## It handles visual positioning, z-indexing and collision layers based on the z_axis value.
class_name PerspectiveTileMapLayer extends TileMapLayer


## Representation of the height of the tilemap on the third axis.
@export var z_axis := 0:
	set(value):
		z_axis = value
		position.y = -value
		z_index = value
		if not Engine.is_editor_hint():
			_set_collision_bits_from_z_axis()


## The Z collision layer the node is on
var z_layer : int :
	get():
		@warning_ignore("integer_division")
		return z_axis / MapGlobals.LAYER_HEIGHT


## Duplicates the tile_set ressource as soon as it is assigned to make it unique
func _ready() -> void:
	if not Engine.is_editor_hint():
		self.tile_set = self.tile_set.duplicate()  # Makes the tileset unique


## Returns a rect equal to the area taken by the tilemap in the game world
func get_world_rect() -> Rect2:
	return Rect2(
		get_used_rect().position * tile_set.tile_size, 
		get_used_rect().size * tile_set.tile_size
		)


## Initializer. Returns a new tilemap with the given tile_set value
static func new_with_tileset(_tile_set : TileSet) -> PerspectiveTileMapLayer:
	var tile_map_layer : PerspectiveTileMapLayer
	tile_map_layer = PerspectiveTileMapLayer.new()
	tile_map_layer.tile_set = _tile_set
	return tile_map_layer


## Sets the collision bits based on the z height of the tilemap
func _set_collision_bits_from_z_axis() -> void:
	if not tile_set == null:
		tile_set.set_physics_layer_collision_layer(
			0, MapGlobals.get_z_collision_masks(z_layer, true, false)
			)
		tile_set.set_physics_layer_collision_layer(
			1, MapGlobals.get_z_collision_masks(z_layer, false, true)
			)


## Returns every polygon for a given tileset physic layer.
func get_collision_polygons(physic_layer : int) -> Array[PackedVector2Array]:
	var tile : TileData
	var polygon : PackedVector2Array
	var polygons : Array[PackedVector2Array]
	
	polygons = []
	for cell in get_used_cells():
		tile = get_cell_tile_data(cell)
		for i in tile.get_collision_polygons_count(physic_layer):
			polygon = []
			for point in tile.get_collision_polygon_points(physic_layer, i):
				polygon.append(point + map_to_local(cell))
			polygons.append(polygon)
	return polygons
	
	
