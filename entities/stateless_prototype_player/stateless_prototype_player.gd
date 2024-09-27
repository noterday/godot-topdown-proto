# Main class for the player character.
# Handles inputs. Currently mostly test code. Undocumented.
# Has a simple jump to test physics.
extends PerspectiveCharacter2D


# Node connections
@onready var Anim := $"Z-Axis/PerspectiveAnimatedSprite2D"


@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_descent : float


@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak)
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak))
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent))


## Movement speed of the player
@export var speed = 120


## The direction of movement on the current frame
@onready var movement_direction := Vector2(0, 0)


# Ran every frame. Processes inputs, animates and moves the player
func _physics_process(delta: float) -> void:
	check_inputs() # Move to states
	start_animation() # Move to states.
	z_velocity += get_jump_gravity() * delta # Custom to player. Will move to jump state.
	move_character(delta) # Custom to player.


# Processes the user input for the player character
func check_inputs() -> void:
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_pressed("debug_rise_up"):
		self.z_axis += 1
	elif Input.is_action_pressed("debug_rise_down"):
		self.z_axis -= 1
	if Input.is_action_just_pressed("jump"):
		jump()


# Execute the jump action
func jump():
	if is_on_z_floor():
		z_velocity = jump_velocity


# Get the jump gravity correspoding the current half of the jump arc
func get_jump_gravity() -> float:
	return jump_gravity if z_velocity > 0.0 else fall_gravity


# Starts movement animations
func start_animation():
	if movement_direction.x < 0:
		Anim.play("walk_left")
	elif movement_direction.x > 0:
		Anim.play("walk_right")
	elif movement_direction.y < 0:
		Anim.play("walk_up")
	elif movement_direction.y > 0:
		Anim.play("walk_down")
	else:
		Anim.play("walk_down")


# Moves the character according to the speed and movement direction
func move_character(delta) -> void:
	z_move_and_collide(delta)
	velocity = movement_direction * speed
	move_and_slide()
