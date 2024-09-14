# Global values used and utility functions for mapping.
extends Node


# The standard size of a tile.
# This is also the number of Z unit between each collision layers.
const TILE_SIZE := 8
enum TILE_MASKS {FLOOR = 8, WALL = 16, EDGE = 24}


# Creates a bitmask for the floor/wall/edge collision layers
func get_z_collision_masks(height : int, floor : bool, wall : bool, edge : bool) -> int:
	var mask := 0
	height %= TILE_SIZE # Loops around every TILE_SIZE tiles
	if floor:
		mask |= (1 << height + TILE_MASKS.FLOOR)
	if wall:
		mask |= (1 << height + TILE_MASKS.WALL)
	if edge:
		mask |= (1 << height + TILE_MASKS.EDGE)
	return mask
