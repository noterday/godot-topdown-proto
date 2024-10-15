class_name RunningJumpState extends MovingCharacterState
## A state for a jump without the ability to strafe back


@export var speed := 90


@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float


@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	parent.xy_direction = parent.facing_direction
	parent.speed = speed
	start_animation()
	if parent.is_on_z_floor():
		parent.z_velocity = jump_velocity


func physics_process(delta):
	parent.z_velocity += _get_jump_gravity() * delta
	parent.move(delta)
	if parent.is_on_z_floor() or parent.z_axis == 0:
		switch_to_state.emit("WalkState")


# Get the jump gravity correspoding the current half of the jump arc
func _get_jump_gravity() -> float:
	return jump_gravity if parent.z_velocity > 0.0 else fall_gravity


func start_animation():
	if parent.facing_direction.y < 0:
		parent.animation.play("jump_up")
	elif parent.facing_direction.y > 0:
		parent.animation.play("jump_down")
	elif parent.facing_direction.x < 0:
		parent.animation.play("jump_left")
	elif parent.facing_direction.x > 0:
		parent.animation.play("jump_right")
