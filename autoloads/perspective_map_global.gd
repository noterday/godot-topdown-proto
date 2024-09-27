## Global value and utility functions related to tilemaps and collisions
extends Node


## The standard size of a tile
## Determines the number of Z unit between each collision layers
## The size of tilesets should match this value to avoid visual and collision bugs
const TILE_SIZE := 8


## Starting value for the 3 types of map collisions (floor, walls, floor edges)
enum TILE_MASKS {FLOOR = 8, WALL = 16, EDGE = 24}


## Creates a bitmask for the floor/wall/edge collision layers
func get_z_collision_masks(height : int, floors : bool, walls : bool, edges : bool) -> int:
	var mask := 0
	height %= TILE_SIZE # Loops around every TILE_SIZE tiles
	if floors:
		mask |= (1 << height + TILE_MASKS.FLOOR)
	if walls:
		mask |= (1 << height + TILE_MASKS.WALL)
	if edges:
		mask |= (1 << height + TILE_MASKS.EDGE)
	return mask
