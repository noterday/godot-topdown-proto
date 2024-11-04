## Should manage a bunch of tilemap_layers.
## Manages dynamically loading them (maybe lol)
## Manages doing their navigation meshes globally (TODO TODO HERE).
extends Node2D


# Polygons generated for every layer of the map. Used to generate a 3D Navigation mesh.
# These are kept in memory even once the navmesh is created, for debug visualisation.
@onready var _navigation_polygons : Dictionary


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gather_navigation_polygons()
	navmesh_creation.call_deferred()


func gather_navigation_polygons() -> void:
	_navigation_polygons = {}
	# TODO: Iterate through all children tilemap layers, collecting polygons.
	# Merge these polygons if they are on the same height.


func navmesh_creation() -> void:
	# Create a new navigation map.
	var map: RID = NavigationServer3D.map_create()
	NavigationServer3D.map_set_up(map, Vector3.UP)
	NavigationServer3D.map_set_active(map, true)

	# Create a new navigation region and add it to the map.
	var region: RID = NavigationServer3D.region_create()
	NavigationServer3D.region_set_transform(region, Transform3D())
	NavigationServer3D.region_set_map(region, map)

	# HALT #
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
