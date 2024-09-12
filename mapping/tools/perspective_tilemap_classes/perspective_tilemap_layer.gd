# A tilemap layer made to exist in the 3/4 view perspective of the game.
# It handles visual positioning, z-indexing and collision layers based on the z_axis value.

class_name PerspectiveTileMapLayer extends TileMapLayer

# Representation of the height of the tilemap on the third axis
@export var z_axis := 0:
	# The setter for z_axis insures all perspective related effects are updated.
	set(value):
		z_axis = value
		position.y = -value
		z_index = value
		set_collision_bits_from_z_axis()


# Sets the collision bits based on the z height of the tilemap
func set_collision_bits_from_z_axis() -> void:
	var layer = z_axis / 8
	tile_set.set_physics_layer_collision_layer(0, 1 << ((layer % 8)+16))
	tile_set.set_physics_layer_collision_layer(1, 1 << ((layer % 8)+24))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Makes the tileset ressource unique for each node to customize the physics layers later.
	self.tile_set = self.tile_set.duplicate()
