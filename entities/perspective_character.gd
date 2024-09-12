## A Character2D which respects the 3/4 perspective and collision rules.
# 

class_name PerspectiveCharacter2D extends CharacterBody2D


## The following Node2D and it's children will have pixel accurate z_index graphical updates (optional).
@export var z_axis_root_node : Node2D
## The following collision box should have manage floor edge detection
@export var floor_collision : CollisionShape2D
## The starting height layer of the node
# The initial height value determines the z_index initial state.
# Afterwards, the z_index setter manages height.
@export var height : int = 0:
	set(value):
		if height != value:
			position.y += (height - value) * MapGlobals.TILE_SIZE
			height = value
			set_height_collision_masks()


# The third axis of movement for the sprite.
# Automatically updates visual, z-index and collision.
@onready var z_axis := 0:
	set(value):
		value = max(0, value) # Prevent negative values
		z_axis = value # Set the value
		if z_axis_root_node: # Adjust the visual of the z_axis affected child nodes if they exist
			z_axis_root_node.position.y = -(value % MapGlobals.TILE_SIZE)
			z_axis_root_node.z_index = value
		# Adjust the height value
		height = value / MapGlobals.TILE_SIZE


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	z_axis = height * MapGlobals.TILE_SIZE


# SEts the collision masks when the height is updated.
func set_height_collision_masks() -> void:
	for i in range(0, 8):
		set_collision_mask_value(17+i, false)
		set_collision_mask_value(25+i, false)
		if i == height:
			set_collision_mask_value(17+i, true)
			set_collision_mask_value(25+i, true)
