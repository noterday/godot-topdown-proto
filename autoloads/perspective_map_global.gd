## Global value and utility functions related to tilemaps and collisions
extends Node


## The standard height of a tile
## Determines the number of Z unit between each collision layers
## WARNING: Due to bad coding on my part, rendering and collisions break if this is different than 8.
const TILE_HEIGHT := 8


## Starting masking layer index for the 2 types of tilemap collisions (floor & walls)
enum TILE_MASKS {FLOOR = 16, WALL = 24}

## Index of the tileset physics layers. Unfortunately, tileset physics layers cannot be named.
enum TILESET_PHYSICS_LAYERS {FLOOR = 0, WALL = 1}


## Creates a bitmask for the floor/wall/edge collision layers
# TODO: Change this to respect existing masks on the non floor/wall layers.
func get_z_collision_masks(height : int, floors : bool, walls : bool) -> int:
	var mask := 0
	height %= TILE_HEIGHT # Loops around every TILE_HEIGHT tiles
	if floors:
		mask |= (1 << height + TILE_MASKS.FLOOR)
	if walls:
		mask |= (1 << height + TILE_MASKS.WALL)
	return mask
