@tool
## A tilemap used to group PerspectiveTilemap.
## Manages the Z-axis position of it's children based on tree order
## This tilemap layer itself has no useful properties but can be used as a background.
class_name PerspectiveTileMapLayerGroup extends TileMapLayer


## The bottom of the floor. Increasing this will create a floating platform.
## TODO: Properly implement this.
@export var bottom : int = 0

# Set to a known node for learning purpose. Later it should be generated in code.
@onready var nav_region : NavigationRegion2D


## Sets the z_axis value of all PerspectiveTileMapLayer children.
func _ready() -> void:
	update_child_layer_z_axis()


func update_child_layer_z_axis():
	var i := 0
	for node in get_children(true):
		if node is PerspectiveTileMapLayer:
			node.z_axis = i * MapGlobals.LAYER_HEIGHT
			i += 1
	

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		update_child_layer_z_axis()
