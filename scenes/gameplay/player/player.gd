# Script handling the player character. Inputs related to gameplay are handled here.
#
# The player character has different actionable states, like walking, jumping, attacking.
# Theres are managed with a simple state machine to easily switch between them.
extends CharacterBody2D


# Node references
@onready var Sprite = $AnimatedSprite2D
@onready var CollisionHandler = $CollisionHandler


# Variables
@onready var movement_vector := Vector2(0,0) # The direction of movement without velocity
@onready var state : PlayerCharacterState # The current player state
@export var height := 0: # The height of the player on the z-axis. Also used for z-indexing.
	set(value): # The height is limited between 0 and 32. (this is done to be able ot tie it to collision layers later.)
		if value >= 0 and value <= 32:
			height = value
			z_index = height


# Initializes the player by putting them in the normal walking state
func _ready():
	height = 1
	state = MovingAround.new(self)


# Asks the current state to manage the player inputs
func process_inputs(delta):
	state.process_inputs(delta)


# Base class for the player state machine
class PlayerCharacterState:
	var player
	func _init(_player_node : CharacterBody2D):
		self.player = _player_node
	
	# Any button press done by the player should be handled here, in child classes.
	func process_inputs(delta):
		pass


# Normal movement gameplay state
class MovingAround extends PlayerCharacterState:
	var speed := 80
	
	# Move around according to the player speed
	func process_inputs(_delta):
		var input_direction = Input.get_vector("movement_left", "movement_right", "movement_up", "movement_down")
		player.velocity = input_direction * speed
		player.velocity = player.CollisionHandler.process_collision(player.height, player.velocity)
		player.move_and_slide()
		turn_and_animate(input_direction)
	
	# Turns the player if the direction changed and starts the movement animation
	func turn_and_animate(input_direction):
		var new_anim
		if input_direction.y < 0:
			new_anim = "walk_up"
		elif input_direction.y > 0:
			new_anim = "walk_down"
		elif input_direction.x < 0:
			new_anim = "walk_left"
		elif input_direction.x > 0:
			new_anim = "walk_right"
		if Input.is_action_just_released("ui_accept"):
			player.height += 1
		elif Input.is_action_just_released("ui_cancel"):
			player.height -= 1
		if new_anim and (not player.Sprite.is_playing() or player.Sprite.animation != new_anim):
			player.Sprite.play(new_anim)
