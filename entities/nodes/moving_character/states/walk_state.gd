class_name WalkState extends MovingCharacterState


@export var speed := 60


func enter() -> void:
	parent.speed = speed


func handle_movement_inputs(direction : Vector2) -> void:
	parent.xy_direction = direction
	start_animation(direction)


func physics_process(delta) -> void:
	parent.z_velocity = -100
	parent.move(delta)


func handle_run_inputs(direction : Vector2) -> void:
	parent.xy_direction = direction
	switch_to_state.emit("RunState")


func handle_jump_input() -> void:
	switch_to_state.emit("JumpState")


func start_animation(direction : Vector2):
	if direction.y < 0:
		parent.animation.play("walk_up")
		parent.facing_direction = Vector2(0, -1)
	elif direction.y > 0:
		parent.animation.play("walk_down")
		parent.facing_direction = Vector2(0, 1)
	elif direction.x < 0:
		parent.animation.play("walk_left")
		parent.facing_direction = Vector2(-1, 0)
	elif direction.x > 0:
		parent.animation.play("walk_right")
		parent.facing_direction = Vector2(1, 0)
	else:
		if parent.facing_direction.y < 0:
			parent.animation.play("idle_up")
		elif parent.facing_direction.y > 0:
			parent.animation.play("idle_down")
		elif parent.facing_direction.x < 0:
			parent.animation.play("idle_left")
		elif parent.facing_direction.x > 0:
			parent.animation.play("idle_right")
