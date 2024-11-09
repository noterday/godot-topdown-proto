## Global value and utility functions related to tilemaps and collisions
extends Node


## The total amount of height layers possible
const MAX_LAYERS := 8


## The standard height of a tile
## Determines the number of Z units between each collision layers and tilemap layers
# WARNING: The entire physics system depends on this value.
# This was set to 8 to match an older tileset cell size. Changing this value could break things.
const LAYER_HEIGHT := 8


## Starting masking layer index for the 2 types of tilemap collisions (floor & walls)
enum TILE_MASKS {FLOOR = 16, WALL = 24}


## Index of the tileset physics layers. Unfortunately, tileset physics layers cannot be named.
enum TILESET_PHYSICS_LAYERS {FLOOR = 0, WALL = 1}


## A reference to the currently active navigation map. Used by agents to register it.
var current_navigation_map : RID:
	set(value):
		current_navigation_map = value
		current_navigation_map_update.emit()

## A signal to tell agents when to update their navigation maps
signal current_navigation_map_update()


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



## This utility function exists to help with operations on navigation meshes
## It returns an array of polygon points smaller than the original, by iteratively merging polygons.
## [br]If 'bound' is set to a value higher than 0, 
## the function will not merge polygons large than it's size on either axis.
func merge_polygons(polygons : Array[PackedVector2Array], bound : float = 0) -> Array[PackedVector2Array]:
	var polygon_a : PackedVector2Array
	var polygon_b : PackedVector2Array
	var polygons_to_remove : Array
	var index_to_remove : Dictionary
	var merged_polygons : Array[PackedVector2Array]
	var minv : Vector2
	var maxv : Vector2
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
				
				# The merged polygon would be too big, so skip to the next loop.
				if bound >= 0: # Unset value ignores this check
					minv = Vector2(pow(2,31)-1, pow(2,31)-1)
					maxv = minv * -1
					for v in merged_polygons[0]:
						minv = Vector2(min(minv.x, v.x),min(minv.y, v.y))
						maxv = Vector2(max(maxv.x, v.x),max(maxv.y, v.y))
					if Vector2(maxv - minv).x > bound or Vector2(maxv - minv).y > bound:
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
