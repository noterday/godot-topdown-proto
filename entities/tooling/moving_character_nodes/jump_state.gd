class_name JumpState extends MovingCharacterState


@export var speed := 50

@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float


@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))


func enter() -> void:
	parent.speed = speed
	start_animation()
	if parent.is_on_z_floor():
		parent.z_velocity = jump_velocity


func physics_process(delta):
	parent.z_velocity += _get_jump_gravity() * delta
	parent.move(delta)
	if parent.is_on_z_floor():
		switch_to_state.emit("WalkState")


func handle_movement_inputs(direction : Vector2) -> void:
	parent.xy_direction = direction


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
