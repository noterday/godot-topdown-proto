## A Character2D which respects the 3/4 perspective and collision rules.
class_name PerspectiveCharacter2D extends CharacterBody2D


# Signals
@warning_ignore("unused_signal")
signal collided_with_floor


## The third axis of movement for the sprite.
## Automatically updates visual, z-index and collision.
@export var z_axis := 0.0:
	set(value):
		# Clamp value between 0 and LAYER_HEIGHT * MAX_LAYERS
		value = min(MapGlobals.LAYER_HEIGHT * MapGlobals.MAX_LAYERS, max(0, value)) 
		if floor_collision: # Collide with floor if you have floor collisions
			value = _z_axis_collision_floor_check(value) 
		_z_axis_position_update(z_axis, value) # Done before setting z_axis to compare old vs new
		z_axis = value
		_z_collision_mask_update()
		# Adjust the visual of the z-axis visual nodes
		if visual_branch:
			visual_branch.position.y = -(int(z_axis) % MapGlobals.LAYER_HEIGHT)
			visual_branch.z_index = value


## The Z collision layer the node is on
var z_layer : int :
	get():
		@warning_ignore("integer_division")
		return z_axis / MapGlobals.LAYER_HEIGHT


## A 3D Global position vector usable in navigation calculations
var navigation_position : Vector3 :
	get():
		return Vector3(
			global_position.x,
			z_layer * MapGlobals.LAYER_HEIGHT,
			global_position.y
			)

@onready var z_velocity : float = 0.0


## The following Node2D and it's children will have pixel accurate z_index graphical updates (optional).
## Graphical nodes must be under a branch of this node, otherwise Character will appear to jump in large steps on the z-axis.
@export var visual_branch : Node2D


## The following collision box should have manage floor edge detection.
@export var floor_collision : CollisionShape2D


## If a floor collision is set, this node will hold 8 area2D with the same collision shape, meant to floors above and under the character.
# It's necessary to check every possible collision layer for floor detection each frame.
# Because it's impossible to update collision masks and recalculate more than once per frame.
# This allows snap-to-floor functionality to work for large z-axis movement.
@onready var z_floor_detection_area_holder : Node2D


## Creates additional node structures based on the chosen editor values when entering the scene tree.
func _enter_tree() -> void:
	_create_z_collision_area()
	_z_collision_mask_update()


## Creates a set of 8 Area2D which enable floor detection on the z-axis.
## Depends on the 'floor_collision' value to be set to a valid collision shape.
func _create_z_collision_area() -> void:
	var z_collision_area : Area2D
	if not z_floor_detection_area_holder and floor_collision:
		z_floor_detection_area_holder = Node2D.new()
		z_floor_detection_area_holder.name = "Z-Floor-Detection-Area-Holder"
		for i in range(MapGlobals.MAX_LAYERS):
			z_collision_area = Area2D.new()
			z_collision_area.name = "Z-Collision-Area " + str(i)
			z_collision_area.collision_mask = MapGlobals.get_z_collision_masks(i, true, false)
			z_collision_area.add_child(floor_collision.duplicate())
			z_collision_area.position.y -= i * MapGlobals.LAYER_HEIGHT
			z_floor_detection_area_holder.add_child(z_collision_area)
		add_child(z_floor_detection_area_holder)


## Updates the CharacterBody2D position vector when reaching a multiple of LAYER_HEIGHT.
func _z_axis_position_update(old : int, new : int) -> void:
	old = old / MapGlobals.LAYER_HEIGHT
	new = new / MapGlobals.LAYER_HEIGHT
	if new != old:
		position.y += (old - new) * MapGlobals.LAYER_HEIGHT
		if floor_collision:
			z_floor_detection_area_holder.position.y -= (old - new) * MapGlobals.LAYER_HEIGHT


# Update the collision mask of the CharacterBody2D according to the Z axis
func _z_collision_mask_update() -> void:
	collision_mask = MapGlobals.get_z_collision_masks(z_layer, false, true)


## Attemps to collide with floor between the current Z-position and the given destination.
# Used for floor collisions. A signal is fired when a collision happens.
func _z_axis_collision_floor_check(destination : float) -> float:
	var floor_z : float
	for area in z_floor_detection_area_holder.get_children(): # Potentially slow-ish?
		if area.has_overlapping_bodies():
			floor_z = -area.position.y
			if floor_z > z_axis and floor_z <= destination: # Upward
				destination = floor_z
				emit_signal("collided_with_floor")
			elif floor_z <= z_axis and floor_z >= destination: # Downward
				destination = floor_z
				emit_signal("collided_with_floor")
			 # Check if clipped under a floor
			elif (floor_z - z_axis) > 0 and (floor_z - z_axis) < MapGlobals.LAYER_HEIGHT:
				destination = floor_z
				emit_signal("collided_with_floor")
	return destination


## Apply z_velocity to the z_axis of the CharacterBody2D.
## Should be called before 'move_and_collide' or 'move_and_slide'.
func z_move_and_collide(delta) -> void:
	if is_on_z_floor() and z_velocity < 0.0:
		z_velocity = 0
	z_axis += z_velocity * delta


## A utility function to verify if the given object is touching the floor.
## Being "on the floor" is defined as colliding with a floor collision, and being at the same z-position as it.
# TODO: There may be special cases in the future to handle ramps and stairs (uneven height tiles).
func is_on_z_floor() -> bool:
	if not floor_collision:
		return true
	if z_floor_detection_area_holder.get_child(z_layer).has_overlapping_bodies():
		if int(z_axis) % MapGlobals.LAYER_HEIGHT == 0:
			return true
	return false
