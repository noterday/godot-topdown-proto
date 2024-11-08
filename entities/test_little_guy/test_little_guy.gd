extends MovingCharacter


## A Node3D which holds navigation nodes. Should have a NavigationAgent3D as a child.
@onready var node3d_navigation_node : Node3D
@onready var nav_agent : NavigationAgent3D


func _ready() -> void:
	node3d_navigation_node = Node3D.new()
	node3d_navigation_node.name = "Navigation"
	add_child(node3d_navigation_node)
	nav_agent = NavigationAgent3D.new()
	
	node3d_navigation_node.add_child(nav_agent)
	nav_agent.velocity_computed.connect(Callable(_on_velocity_computed))


func _process(delta: float) -> void:
	nav_agent.set_navigation_map(MapGlobals.current_map)
	node3d_navigation_node.position = navigation_position
	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(nav_agent.get_navigation_map()) == 0:
		return
	if nav_agent.is_navigation_finished():
		return
	
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	var new_velocity: Vector3 = node3d_navigation_node.global_position.direction_to(next_path_position) * 60
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)


# Setting the movement target on signal receive from the player (debug)
func debug_player_jump_callback(player_nav_pos : Vector3) -> void:
	nav_agent.set_target_position(player_nav_pos) 


func _on_velocity_computed(safe_velocity : Vector3):
	velocity = Vector2(safe_velocity.x, safe_velocity.z)
	move_and_slide()
