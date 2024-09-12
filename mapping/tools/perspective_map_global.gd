# Global values used and utility functions for mapping.
extends Node


# The standard size of a tile.
# This is also the number of Z unit between each collision layers.
const TILE_SIZE := 8


# TODO: Util class for bit manips. To be used in perspective tilemap.
func get_collision_layer_bit(value : int) -> int:
	return 0
