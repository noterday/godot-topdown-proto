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
