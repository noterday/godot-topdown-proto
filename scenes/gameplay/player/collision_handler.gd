# The collision handler uses a grid of 3x3 points around the player to handle wall and floor collisions.
# Other collisions, such as collisions with enemies, are handled by standard physics functions.
extends Node2D


# Node references
@onready var BottomLeft = $BottomLeft
@onready var BottomCenter = $BottomCenter
@onready var BottomRight = $BottomRight
@onready var CenterLeft = $CenterLeft
@onready var CenterCenter = $CenterCenter
@onready var CenterRight = $CenterRight
@onready var TopLeft = $TopLeft
@onready var TopCenter = $TopCenter
@onready var TopRight = $TopRight


# Variables
@export var SPEED_LOSS_ON_SLIDING = 0.5 # Friction applied when the player moves sideway into an opening
@export var current_map : TileMap # Reference to the current map.

# Both of the following arrays are set to work in numpad notation, so they have a dummy null value at the start
# An array listing which direction around the player has a walkable floor tile
@onready var floor = [ null, # Dummy
false, false, false, 		 # Top
false, false, false, 		 # Middle
false, false, false] 		 # Bottom
# An array that stores the default position of each collision point.
@onready var default_points_pos = [ null, # Dummy
	BottomLeft.position, BottomCenter.position, BottomRight.position,
	CenterLeft.position, CenterCenter.position, CenterRight.position,
	TopLeft.position, TopCenter.position, TopRight.position,
]


# When moving diagonaly, the colision point for that diagonal is moved inward by 1 pixel.
# This fixes some visual stuttering when walking diagonaly into a wall, 
# caused by the player clipping and being pushed back every frame.
func update_point_positions(velocity):
	TopLeft.position = default_points_pos[7]
	TopRight.position = default_points_pos[9]
	BottomLeft.position = default_points_pos[1]
	BottomRight.position = default_points_pos[3]
	if velocity.x < 0 and velocity.y < 0:
		TopLeft.position = default_points_pos[7] + Vector2(1, 1)
	elif velocity.x < 0 and velocity.y > 0:
		BottomLeft.position = default_points_pos[1] + Vector2(1, -1)
	elif velocity.x > 0 and velocity.y < 0:
		TopRight.position = default_points_pos[9] + Vector2(-1, 1)
	elif velocity.x > 0 and velocity.y > 0:
		BottomRight.position = default_points_pos[3] + Vector2(-1, -1)


# The floor array is updated to know the walkable space around the player
func update_floor_info(height):
	floor[1] = is_point_on_floor(height, BottomLeft)
	floor[2] = is_point_on_floor(height, BottomCenter)
	floor[3] = is_point_on_floor(height, BottomRight)
	floor[4] = is_point_on_floor(height, CenterLeft)
	floor[5] = is_point_on_floor(height, CenterCenter)
	floor[6] = is_point_on_floor(height, CenterRight)
	floor[7] = is_point_on_floor(height, TopLeft)
	floor[8] = is_point_on_floor(height, TopCenter)
	floor[9] = is_point_on_floor(height, TopRight)


# Returns a modified velocity vector with the collision applied
# Collision is detected when the player tries to move into a floorless tile
func process_collision(height, velocity):
	update_point_positions(velocity)
	update_floor_info(height)
	return collide_with_floorless_areas(height, velocity)


# Collision is checked for the direction the player is moving in
# If the player is on the edge of an opening, walking straight forward
# will cause they to slide off sideway into that opening.
func collide_with_floorless_areas(height, velocity):
	if velocity.x < 0:
		if not is_west_walkable():
			if is_north_walkable() and not velocity.y:
				velocity.y = velocity.x * SPEED_LOSS_ON_SLIDING
			elif is_south_walkable() and not velocity.y:
				velocity.y = - velocity.x * SPEED_LOSS_ON_SLIDING
			velocity.x = 0
	elif velocity.x > 0:
		if not is_east_walkable():
			if is_north_walkable() and not velocity.y:
				velocity.y = - velocity.x * SPEED_LOSS_ON_SLIDING
			elif is_south_walkable() and not velocity.y:
				velocity.y = velocity.x * SPEED_LOSS_ON_SLIDING
			velocity.x = 0
	if velocity.y < 0:
		if not is_north_walkable():
			if is_west_walkable() and not velocity.x:
				velocity.x = velocity.y * SPEED_LOSS_ON_SLIDING
			elif is_east_walkable() and not velocity.x:
				velocity.x = - velocity.y  * SPEED_LOSS_ON_SLIDING
			velocity.y = 0
	elif velocity.y > 0:
		if not is_south_walkable():
			if is_west_walkable() and not velocity.x:
				velocity.x = - velocity.y * SPEED_LOSS_ON_SLIDING
			elif is_east_walkable() and not velocity.x:
				velocity.x = velocity.y  * SPEED_LOSS_ON_SLIDING
			velocity.y = 0
	return velocity

# Reads the current tilemap to see if a point overlaps a floor tile
func is_point_on_floor(height : int, point : Marker2D):
	var map_coords = current_map.local_to_map(point.global_position)
	var tile_data = current_map.get_cell_tile_data(height, map_coords)
	if tile_data and tile_data.get_custom_data("is_floor"):
		return true


# Test if you can move north
func is_north_walkable():
	return floor[7] and floor[8] and floor[9]


# Test if you can move east
func is_east_walkable():
	return floor[3] and floor[6] and floor[9]


# Test is you can move west
func is_west_walkable():
	return floor[1] and floor[4] and floor[7]


# Test if you can move south
func is_south_walkable():
	return floor[1] and floor[2] and floor[3]
