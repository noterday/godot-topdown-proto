## A tilemap used to group PerspectiveTilemap.
## Will manage the Z-axis position of it's children based on tree order
## This tilemap itself has no special properties but can be used as a collision-less background layer.
class_name PerspectiveTileMapLayerGroup extends TileMapLayer


## This node will set the z_axis value of all PerspectiveTileMapLayer children.
func _ready() -> void:
	var i := 0
	for node in get_children():
		if node is PerspectiveTileMapLayer:
			node.z_axis = i * MapGlobals.TILE_SIZE
			i += 1
