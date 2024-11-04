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


## Duplicates the tile_set ressource as soon as it is assigned to make it unique.
func _ready() -> void:
	if not Engine.is_editor_hint():
		self.tile_set = self.tile_set.duplicate()  # Makes the tileset unique


# Returns a rect representing the space taken by the tilemap in the game world
func get_world_rect() -> Rect2:
	return Rect2(
		get_used_rect().position * tile_set.tile_size, 
		get_used_rect().size * tile_set.tile_size
		)


## Returns a new instance with the tileset value set
static func new_with_tileset(_tile_set : TileSet) -> PerspectiveTileMapLayer:
	var tile_map_layer : PerspectiveTileMapLayer
	tile_map_layer = PerspectiveTileMapLayer.new()
	tile_map_layer.tile_set = _tile_set
	return tile_map_layer


## Sets the collision bits based on the z height of the tilemap
func _set_collision_bits_from_z_axis() -> void:
	if not tile_set == null:
		@warning_ignore("integer_division")
		var z_layer = z_axis / 8
		tile_set.set_physics_layer_collision_layer(0, MapGlobals.get_z_collision_masks(z_layer, true, false))
		tile_set.set_physics_layer_collision_layer(1, MapGlobals.get_z_collision_masks(z_layer, false, true))


## Creates an return a set of polygon representing the floor collision.
## A minimal set of polygons is created to represent the entire space of the floor.
func get_floor_polygon() -> Array[PackedVector2Array]:
	var tile : TileData
	var polygon_a : PackedVector2Array
	var polygon_b : PackedVector2Array
	var polygons : Array[PackedVector2Array]
	
	# Extract every collision polygon used for 'Floor' collisions
	polygons = []
	for cell in get_used_cells():
		tile = get_cell_tile_data(cell)
		for i in tile.get_collision_polygons_count(MapGlobals.TILESET_PHYSICS_LAYERS.FLOOR):
			polygon_a = []
			for point in tile.get_collision_polygon_points(
				MapGlobals.TILESET_PHYSICS_LAYERS.FLOOR, i
				):
				polygon_a.append(point + map_to_local(cell))
			polygons.append(polygon_a)
			
	# Merge the polygons into as few polygons as possible
	# Adapted from: https://gist.github.com/afk-mario/15b5855ccce145516d1b458acfe29a28
	var polygons_to_remove : Array
	var index_to_remove : Dictionary
	var merged_polygons : Array[PackedVector2Array]
	
	while true:
		# Clear the polygons to remove
		polygons_to_remove = []
		index_to_remove = {}
		# Iterate through every polygon
		for i in polygons.size():
			# Skip if the polygon was marked for removal in a previous iteration
			if index_to_remove.get(i, false) == true:
				continue
			polygon_a = polygons[i]
			
			# Test merging with every other available polygon
			# from the start of the list up to the current polygon
			for j in i:
				# Skip this second polygon if its due for removal
				if index_to_remove.get(j, false) == true:
					continue 
				polygon_b = polygons[j]
				merged_polygons = Geometry2D.merge_polygons(polygon_a, polygon_b)
				
				# The polygons dind't merge so skip to the next loop
				if merged_polygons.size() != 1:
					continue
				
				# Replace the second polygon with the merged one
				polygons[j] = merged_polygons[0]
				
				# Mark to remove the first polygon which has been merged
				polygons_to_remove.append(polygon_a)
				index_to_remove[i] = true
				break

		# There is no polygon to remove so we finished
		if polygons_to_remove.size() == 0:
			break

		# Remove the polygons marked to be removed
		for polygon in polygons_to_remove:
			var index = polygons.find(polygon)
			polygons.pop_at(index)
	
	return polygons
