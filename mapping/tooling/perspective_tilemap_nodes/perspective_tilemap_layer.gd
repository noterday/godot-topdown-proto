## A tilemap layer made to exist in the 3/4 view perspective of the game.
## It handles visual positioning, z-indexing and collision layers based on the z_axis value.
class_name PerspectiveTileMapLayer extends TileMapLayer

## Representation of the height of the tilemap on the third axis.
@export var z_axis := 0:
	set(value):
		z_axis = value
		position.y = -value
		z_index = value
		_set_collision_bits_from_z_axis()


## Sets the collision bits based on the z height of the tilemap
func _set_collision_bits_from_z_axis() -> void:
	@warning_ignore("integer_division")
	var layer = z_axis / 8
	tile_set.set_physics_layer_collision_layer(0, MapGlobals.get_z_collision_masks(layer, true, false , false))
	tile_set.set_physics_layer_collision_layer(1, MapGlobals.get_z_collision_masks(layer, false, true , false))
	tile_set.set_physics_layer_collision_layer(2, MapGlobals.get_z_collision_masks(layer, false, false , true))


## Duplicates the tile_set ressource as soon as it is assigned to make it unique.
func _init() -> void:
	self.tile_set = self.tile_set.duplicate() # This makes the ressource unique
