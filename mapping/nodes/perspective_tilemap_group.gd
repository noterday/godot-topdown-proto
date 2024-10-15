@tool
## A tilemap used to group PerspectiveTilemap.
## Manages the Z-axis position of it's children based on tree order
## This tilemap layer itself has no useful properties but can be used as a background.
class_name PerspectiveTileMapLayerGroup extends TileMapLayer


@export var bottom : int = 0

## Sets the z_axis value of all PerspectiveTileMapLayer children.
func _process(_delta : float) -> void:
	var i := 0
	for node in get_children(true):
		if node is PerspectiveTileMapLayer:
			node.z_axis = i * MapGlobals.TILE_SIZE
			i += 1
