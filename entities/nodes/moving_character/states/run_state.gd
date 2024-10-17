class_name RunState extends MovingCharacterState
## Handles the behavior for a running character.
##
## Primarely useful for the player character is it makes litle difference if
## a NPC is running or walking, beside changing the animation sets.

@export var speed := 120


## Sets the parent speed on entry.
func enter() -> void:
	parent.speed = speed


## Updates the parent's movement direction.
## Will reset to a walking state if stopping or doing a 180 degree turn.
func handle_movement_inputs(direction : Vector2) -> void:
	if (direction == Vector2(0, 0)) or (direction == parent.facing_direction * -1):
		switch_to_state.emit("WalkState")
	parent.xy_direction = direction
	start_animation(direction)


## Moves on the physic step
func physics_process(delta) -> void:
	parent.z_velocity = -100 # Needed to slip off platforms
	parent.move(delta)


## Switches to a running jump state
# TODO: Implement a running jump and call it here.
func handle_jump_input() -> void:
	switch_to_state.emit("RunningJumpState")


## Updates the animation to a running one.
func start_animation(_direction : Vector2):
	if parent.facing_direction.y < 0:
		parent.animation.play("run_up")
	elif parent.facing_direction.y > 0:
		parent.animation.play("run_down")
	elif parent.facing_direction.x < 0:
		parent.animation.play("run_left")
	elif parent.facing_direction.x > 0:
		parent.animation.play("run_right")
