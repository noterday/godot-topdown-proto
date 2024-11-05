## Global value and utility functions related to tilemaps and collisions
extends Node


## The standard height of a tile
## Determines the number of Z units between each collision layers and tilemap layers
# WARNING: The entire physics system depends on this value.
# Everything has been designed with a value of 8 in mind, 
# even if the wall tiles are twice as tall.
# Lower values seem fine. Going above 10 breaks z-indexes.
const LAYER_HEIGHT := 8


## Starting masking layer index for the 2 types of tilemap collisions (floor & walls)
enum TILE_MASKS {FLOOR = 16, WALL = 24}

## Index of the tileset physics layers. Unfortunately, tileset physics layers cannot be named.
enum TILESET_PHYSICS_LAYERS {FLOOR = 0, WALL = 1}


## Creates a bitmask for the floor/wall/edge collision layers
# TODO: Change this to respect existing masks on the non floor/wall layers.
func get_z_collision_masks(height : int, floors : bool, walls : bool) -> int:
	var mask := 0
	height %= LAYER_HEIGHT # Loops around every LAYER_HEIGHT units
	if floors:
		mask |= (1 << height + TILE_MASKS.FLOOR)
	if walls:
		mask |= (1 << height + TILE_MASKS.WALL)
	return mask
