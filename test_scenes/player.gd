# Main class for the player character.
# Handles inputs. Currently mostly test code. Undocumented.
extends PerspectiveCharacter2D

# Node connections
@onready var Anim := $"Z-Axis/PerspectiveAnimatedSprite2D"


## Movement speed of the player
@export var speed = 120


# The direction of movement on the current frame
@onready var movement_direction := Vector2(0, 0)


# Ran every frame. Processes inputs, animates and moves the player
func _physics_process(delta: float) -> void:
	check_inputs()
	start_animation()
	move_character()


# Processes the user input for the player character
func check_inputs() -> void:
	movement_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if Input.is_action_just_pressed("debug_rise_up"):
		self.z_axis += MapGlobals.TILE_SIZE
	elif Input.is_action_just_pressed("debug_rise_down"):
		self.z_axis -= MapGlobals.TILE_SIZE


# Moves the character according to the speed and movement direction
func move_character() -> void:
	velocity = movement_direction * speed
	move_and_slide()


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
