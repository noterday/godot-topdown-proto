## Should manage a bunch of tilemap_layers.
## Manages dynamically loading them (maybe lol)
## Manages doing their navigation meshes globally (TODO TODO HERE).
extends Node2D


# Polygons generated for every layer of the map. Used to generate a 3D Navigation mesh.
# These are kept in memory even once the navmesh is created, for debug visualisation.
@onready var _navigation_polygons : Array[Array]
@onready var map : RID

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gather_navigation_polygons()
	debug_collision_display_step()
	navmesh_creation.call_deferred()
	$Player.debug_player_jumped.connect($TestLittleGuy.debug_player_jump_callback)


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
	map = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map, Vector3.UP)
	NavigationServer3D.map_set_active(map, true)
	MapGlobals.current_map = map

	# Create a new navigation region and add it to the map.
	var region: RID = NavigationServer3D.region_create()
	NavigationServer3D.region_set_transform(region, Transform3D())
	NavigationServer3D.region_set_map(region, map)

	# Create a navigation mesh for the region.
	var new_navigation_mesh: NavigationMesh = NavigationMesh.new()
	var vertices: PackedVector3Array = PackedVector3Array([])
	var polygon_vertices_index: PackedInt32Array = PackedInt32Array([])
	for h in len(_navigation_polygons):
		for nav_poly in _navigation_polygons[h]:
			polygon_vertices_index = []
			for point in nav_poly:
				vertices.append(Vector3(point.x, h * MapGlobals.LAYER_HEIGHT, point.y))
				polygon_vertices_index.append(len(vertices)-1)
			new_navigation_mesh.add_polygon(polygon_vertices_index)
	new_navigation_mesh.set_vertices(vertices)
	NavigationServer3D.region_set_navigation_mesh(region, new_navigation_mesh)
