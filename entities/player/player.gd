extends MovingCharacter
## Script handling the main player character's input
##
## It sends input to it's child state machine node.


signal debug_player_jumped(navigation_position : Vector3)


## Name of the cardinal movement actions. Ordered for use in Input.get_vector
const MOVE_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]


## Input actions which are checked by the double-tap input checker
const DOUBLE_TAP_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]
## The timer length before a double-tap input is forgotten
@export var double_tap_timer_length := 1
# The timer object used to time-out double-taps
@onready var _last_tap_timeout : SceneTreeTimer
# The last remembered input for double-tap checks
@onready var _last_tap : String


## Internal reference to the state machine node. Needed to contact it's active state.
@onready var sm := $StateMachine


# Processes the user input for the player character
func _process(_delta: float) -> void:
	var double_tap = check_double_tap()
	var move_direction = Input.get_vector(
		MOVE_ACTIONS[0], MOVE_ACTIONS[1], 
		MOVE_ACTIONS[2], MOVE_ACTIONS[3])
	if double_tap in MOVE_ACTIONS:
		sm.active_state.handle_run_inputs(move_direction)
	else:
		sm.active_state.handle_movement_inputs(move_direction)
	if Input.is_action_just_pressed("jump"):
		sm.active_state.handle_jump_input()
		# Debug
		debug_player_jumped.emit(navigation_position)


## Checks if a double-tap-able input has been double-tapped and return it's name
func check_double_tap() -> String:
	for key in DOUBLE_TAP_ACTIONS:
		if Input.is_action_just_pressed(key):
			# A timer is created to destroy the stored input after some time
			_last_tap_timeout = get_tree().create_timer(double_tap_timer_length)
			_last_tap_timeout.connect("timeout", _clear_tap_timeout)
			if key == _last_tap:
				return key # Second input within timer
			else:
				_last_tap = key # First input
				break
	return ""


# Removes the remembered input for double-tapping.
func _clear_tap_timeout() -> void:
	_last_tap = ""
