# A tilemap used to group PerspectiveTilemap. Manages their height automatically.
# Mapping done on this layer itself has no special properties or perspective effects.
class_name PerspectiveTileMapLayerGroup extends TileMapLayer


# Called when the node enters the scene tree for the first time.
# Sets the Z height of all it's children PerspectiveTileMapLayer in tree order
func _ready() -> void:
	var i := 0
	for node in get_children():
		if node is PerspectiveTileMapLayer:
			node.z_axis = i * MapGlobals.TILE_SIZE
			i += 1
