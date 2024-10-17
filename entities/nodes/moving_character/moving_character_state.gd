class_name MovingCharacterState extends State
# TODO: Define an interface for standard input (movement + jump)
# This will be used by the player to send input to state
# Should be phrased in a way that entities will be able to use also for AI.


@onready var parent : MovingCharacter


func handle_movement_inputs(_movement_inputs : Vector2) -> void:
	pass


func handle_run_inputs(_movement_inputs : Vector2) -> void:
	pass


func handle_jump_input() -> void:
	pass
