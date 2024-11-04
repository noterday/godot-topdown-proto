extends MovingCharacter


@onready var nav_agent := $NavigationAgent2D


func _on_player_debug_player_jumped(player_position: Vector2i) -> void:
	nav_agent.target_position = player_position


func _process(_delta: float) -> void:
	var next = nav_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next) * 60
	velocity = new_velocity
	move_and_slide()
