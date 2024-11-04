## Abstract class for a state in a state machine
class_name State extends Node


## Signal used for asking the state machine to switch states
## This should be called defered to allow a state to finish execution before inactivating.
@warning_ignore("unused_signal")
signal switch_to_state(state_class_name : Object)


## Called by the state machine upon becoming the active state.
func enter() -> void:
	pass


## Called by the state machine when removing the state from the active slot.
# Usually you could put any code you would want to put here after the "switch_to_state" emission
# But this allows exit code that's defered until the next idle frame
func exit() -> void:
	pass


## Called by the state machine on the engine's main loop tick.
func process(_delta: float) -> void:
	pass


## Called by the state machine on the engine's physics update tick.
func physics_process(_delta: float) -> void:
	pass
