## Should manage a bunch of tilemap_layers.
## Manages dynamically loading them (maybe lol)
## Manages doing their navigation meshes globally (TODO TODO HERE).
extends Node2D


# Polygons generated for every layer of the map. Used to generate a 3D Navigation mesh.
# These are kept in memory even once the navmesh is created, for debug visualisation.
@onready var _navigation_polygons : Array[Array]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gather_navigation_polygons()
	debug_collision_display_step()
	navmesh_creation.call_deferred()


## Iterates through the child nodes to find and merge all floor polygons into optimized shapes.
func gather_navigation_polygons() -> void:
	var tilemaps : Array[PerspectiveTileMapLayer]
	var unmerged_polygons : Array[PackedVector2Array]
	tilemaps = _get_all_tilemaps(self)
	for i in range(MapGlobals.MAX_LAYERS):
		_navigation_polygons.append([])
		unmerged_polygons = []
		for tilemap in tilemaps.filter(func(p_tilemap): return p_tilemap.z_layer == i):
			unmerged_polygons.append_array(
				tilemap.get_collision_polygons(MapGlobals.TILESET_PHYSICS_LAYERS.FLOOR)
				)
		_navigation_polygons[i] = MapGlobals.merge_polygons(unmerged_polygons)


# Used to get every perspective tilemap node recursively
func _get_all_tilemaps(node : Node) -> Array[PerspectiveTileMapLayer]:
	var layers : Array[PerspectiveTileMapLayer] = []
	if node is PerspectiveTileMapLayer:
		layers.append(node)
	if node.get_child_count() > 0:
		for child in node.get_children():
			layers.append_array(_get_all_tilemaps(child))
	return layers


## Creates a node branch where the navigation polygons are assigned to static bodies,
## whenever the 'debug_collisions_hint' is set to true in editor, so they can be visualised.
func debug_collision_display_step() -> void:
	var debug_visual_branch : Node2D
	var static_body : StaticBody2D
	var polygon_shape : CollisionPolygon2D
	if get_tree().debug_collisions_hint == true:
		debug_visual_branch = Node2D.new()
		debug_visual_branch.name = "2D Navmesh Visualisation (debug)"
		add_child(debug_visual_branch)
		for i in len(_navigation_polygons):
			static_body = StaticBody2D.new()
			static_body.position.y = -(i * MapGlobals.LAYER_HEIGHT)
			static_body.collision_layer = 0
			static_body.collision_mask = 0
			static_body.name = "Layer " + str(i)
			debug_visual_branch.add_child(static_body)
			for polygon in _navigation_polygons[i]:
				polygon_shape = CollisionPolygon2D.new()
				polygon_shape.polygon = polygon
				static_body.add_child(polygon_shape)

# TODO: Navmesh creation step
func navmesh_creation() -> void:
	# Create a new navigation map.
	var map: RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map, Vector3.UP)
	NavigationServer3D.map_set_active(map, true)

	# Create a new navigation region and add it to the map.
	var region: RID = NavigationServer3D.region_create()
	NavigationServer3D.region_set_transform(region, Transform3D())
	NavigationServer3D.region_set_map(region, map)

	# TODO: Works needs to happen at this point for the navigation mesh
	# Use the polygons created above
	
	# Before doing any more work here, try to cleanup the usager of TILE_HEIGHT and division by 8.
	# Height inside tilemaps is handled wonkely right now.


# A demo function from the godot docs. Copy pasted here as a reference.
func _custom_setup():

	# Create a new navigation map.
	var map: RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map, Vector3.UP)
	NavigationServer3D.map_set_active(map, true)

	# Create a new navigation region and add it to the map.
	var region: RID = NavigationServer3D.region_create()
	NavigationServer3D.region_set_transform(region, Transform3D())
	NavigationServer3D.region_set_map(region, map)

	# Create a procedural navigation mesh for the region.
	var new_navigation_mesh: NavigationMesh = NavigationMesh.new()
	var vertices: PackedVector3Array = PackedVector3Array([
		Vector3(0, 0, 0),
		Vector3(9.0, 0, 0),
		Vector3(0, 0, 9.0)
	])
	new_navigation_mesh.set_vertices(vertices)
	var polygon: PackedInt32Array = PackedInt32Array([0, 1, 2])
	new_navigation_mesh.add_polygon(polygon)
	NavigationServer3D.region_set_navigation_mesh(region, new_navigation_mesh)

	# Wait for NavigationServer sync to adapt to made changes.
	await get_tree().physics_frame

	# Query the path from the navigation server.
	var start_position: Vector3 = Vector3(0.1, 0.0, 0.1)
	var target_position: Vector3 = Vector3(1.0, 0.0, 1.0)
	var optimize_path: bool = true

	var path: PackedVector3Array = NavigationServer3D.map_get_path(
		map,
		start_position,
		target_position,
		optimize_path
	)

	print("Found a path!")
	print(path)
