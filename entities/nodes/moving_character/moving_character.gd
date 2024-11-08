class_name MovingCharacter extends PerspectiveCharacter2D
# Note: This is a specialized version of perspectivecharacter2D to polute it with like
# a bunch of specific implementation of physics and movement stuff.
# it exists in part to define what the associated state machine can and cannot do.
#
# TODO: Add gravity variables in this and calculation for jump physics.
# Add some kind of exported value to determine if you collide with floor edges or not.


@onready var xy_direction := Vector2(0, 0)
@onready var facing_direction := Vector2(0, 1)
@onready var speed : int = 120


@export var state_machine : StateMachine
@export var animation : AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if state_machine:
		state_machine.setup(self)

# Moves the character according to the speed and movement direction
func move(delta) -> void:
	z_move_and_collide(delta)
	velocity = xy_direction * speed
	move_and_slide()
