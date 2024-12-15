## A map stores every tilemap and object in a given area of the game.
## There should be a single map per area of the game, which holds many tilemaps.
## It generates valid 3D collision meshes according to the floor collisions of all it's children.
extends Node2D


## This value represents the maximum height and width of a merged polygon.
## [br] Setting this too small leads to a high total polygon count.
## [br] Setting this too high leads to more sliver triangles.
const MAX_TILE_MERGING_SIZE : int = 64


## The tilemap used to calculate the camera boundary of the map scene.
@export var camera_bound_tilemap : TileMapLayer


# A Node2D which stores all the entities which are loaded in this map.
# Unused
#@export var entities_container : Node2D


## If set to true and navmesh debugging is active, the navigation polygons will be visualized.
## The resulting polygons on screen are slightly innacurate in that they do not take into account
## the final mesh baking step.
@export var custom_debug_navmesh_visualisation := false


# Polygons generated for every layer of the map. Used to generate a 3D Navigation mesh.
# The first dimension represents each height layer, while the second stores the polygons.
# These are kept in memory even once the navmesh is created, for debug visualisation.
@onready var _navigation_polygons : Array[Array]


# Called when the node enters the scene tree for the first time.
# Generates the polygon and navigation data.
func _ready() -> void:
	create_navigation_data()
	setup_camera_boundary()
	
	# Debug scene stuff. Remove.
	$Entities/Player.debug_player_jumped.connect(
		$Entities/TestLittleGuy.debug_player_jump_callback
		)


func create_navigation_data():
	gather_navigation_polygons()
	debug_navigation_display_step()
	navmesh_creation.call_deferred()


## Iterates through the child nodes to find and merge all floor polygons into optimized shapes.
func gather_navigation_polygons() -> void:
	# Poly triangulation function.
	# Defined as a lambda as its useless elsewere.
	var triangulate = func(old_polys : Array[PackedVector2Array]) -> Array[PackedVector2Array]:
		var new_polys : Array[PackedVector2Array] = []
		var triangle : PackedVector2Array = []
		for poly in old_polys:
			triangle = []
			for point_index in Geometry2D.triangulate_polygon(poly):
				triangle.append(poly[point_index])
				if triangle.size() == 3:
					new_polys.append(triangle)
					triangle = []
		return new_polys
	
	
	var tilemaps : Array[PerspectiveTileMapLayer]
	var unmerged_polygons : Array[PackedVector2Array]
	
	# Fetch every tile collision from the tilemaps
	tilemaps = _get_all_tilemaps(self)
	for i in range(MapGlobals.MAX_LAYERS):
		_navigation_polygons.append([])
		unmerged_polygons = []
		
		# Iterate through the tilemaps by their height
		# Then add every floor cell into the polygon list
		for tilemap in tilemaps.filter(func(p_tilemap): return p_tilemap.z_layer == i):
			unmerged_polygons.append_array(
				tilemap.get_collision_polygons(MapGlobals.TILESET_PHYSICS_LAYERS.FLOOR)
				)
		
		# Create the polygons by first merging them, then triangulating them
		unmerged_polygons = MapGlobals.merge_polygons(unmerged_polygons, MAX_TILE_MERGING_SIZE)
		_navigation_polygons[i] = triangulate.call(unmerged_polygons)


# Used to get every perspective child tilemap node recursively
func _get_all_tilemaps(node : Node) -> Array[PerspectiveTileMapLayer]:
	var layers : Array[PerspectiveTileMapLayer] = []
	if node is PerspectiveTileMapLayer:
		layers.append(node)
	if node.get_child_count() > 0:
		for child in node.get_children():
			layers.append_array(_get_all_tilemaps(child))
	return layers


## Creates a node branch used for visualizing polygons.
## Active only when the navigation debug is on.
func debug_navigation_display_step() -> void:
	var debug_visual_branch : Node2D
	var static_body : StaticBody2D
	var polygon_shape : CollisionPolygon2D
	var possible_colors = [
	Color.AQUA, 
	Color.BLUE_VIOLET, 
	Color.CHOCOLATE,
	Color.DARK_BLUE,
	Color.BISQUE,
	Color.DARK_GOLDENROD,
	Color.GRAY,
	Color.GOLD,
	Color.DARK_OLIVE_GREEN,
	Color.AQUAMARINE]
	if get_tree().debug_navigation_hint and custom_debug_navmesh_visualisation:
		debug_visual_branch = Node2D.new()
		debug_visual_branch.name = "2D Navmesh Visualisation (debug)"
		debug_visual_branch.modulate.a *= 0.2
		add_child(debug_visual_branch)
		for i in len(_navigation_polygons):
			var layer_node : Node2D = Node2D.new()
			layer_node.name = "Layer " + str(i)
			layer_node.position.y -= (i * MapGlobals.LAYER_HEIGHT)
			debug_visual_branch.add_child(layer_node)
			for j in len(_navigation_polygons[i]):
				var polygon2d = Polygon2D.new()
				polygon2d.polygon = _navigation_polygons[i][j]
				polygon2d.color = possible_colors[j % len(possible_colors)]
				layer_node.add_child(polygon2d)


## Creation of the navigation map according to the generated polygon shapes.
## This function sets the generated map as the current global map in the MapGlobals autoload.
func navmesh_creation() -> void:
	# Create a new navigation map.
	var map : RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map, Vector3.UP)
	NavigationServer3D.map_set_active(map, true)
	MapGlobals.current_navigation_map = map

	# Create a new navigation region and add it to the map.
	var region : RID = NavigationServer3D.region_create()
	NavigationServer3D.region_set_transform(region, Transform3D())
	NavigationServer3D.region_set_map(region, map)

	# Create a navigation mesh for the region.
	var new_navigation_mesh : = NavigationMesh.new()
	new_navigation_mesh.agent_radius = 7.5 # Less than half a tile! Maximum before hallways break.
	
	# Bake the polygons into the mesh using a source geometry object.
	var source_geometry_data := NavigationMeshSourceGeometryData3D.new()
	var face : PackedVector3Array
	for h in len(_navigation_polygons):
		for nav_poly in _navigation_polygons[h]:
			face = []
			for point in nav_poly:
				face.append(Vector3(
					point.x,
					h * MapGlobals.LAYER_HEIGHT,
					point.y - (h * MapGlobals.LAYER_HEIGHT)))
			source_geometry_data.add_faces(face, Transform3D())
	NavigationServer3D.bake_from_source_geometry_data(new_navigation_mesh, source_geometry_data)
	
	# Set the baked mesh onto the map.
	NavigationServer3D.region_set_navigation_mesh(region, new_navigation_mesh)


func setup_camera_boundary() -> void:
	var rect : Rect2i
	var tile_size : Vector2i
	if camera_bound_tilemap:
		rect = camera_bound_tilemap.get_used_rect()
		tile_size = camera_bound_tilemap.tile_set.tile_size
		Global.player.camera.limit_left = rect.position.x * tile_size.x
		Global.player.camera.limit_right = rect.end.x * tile_size.x
		Global.player.camera.limit_top = rect.position.y * tile_size.y
		Global.player.camera.limit_bottom = rect.end.y * tile_size.y
