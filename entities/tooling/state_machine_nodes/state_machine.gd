class_name StateMachine extends Node
## State machine implementation for the logic of complex game entities.
##
## Requires every possible states of the machine to be declared as children.
## The parent of this node must connect signals between itself and the state nodes.
## This node does not directly handle any of the communication between it's parent and children.


## The starting state of the machine
@export var starting_state : State


# The currently active state.
# Should only be modified through use of the 
@onready var active_state := starting_state


# Stores references to all the child states and connect to their "switch_state" signal
# The CONNECT_DEFERRED flag means the signal only happens at idle time
# This makes sure the state has the time to finish it's processing switching
# There can still be processing order oddities if a state has an 'await' thread
func _ready() -> void:
	for node in self.get_children():
		node.switch_to_state.connect(_switch_to_state, Object.ConnectFlags.CONNECT_DEFERRED)


func _process(delta: float) -> void:
	active_state.process(delta)


func _physics_process(delta: float) -> void:
	active_state.physics_process(delta)


# Switches the active state to a new one when called
func _switch_to_state(state_class_name : String) -> void:
	active_state.exit()
	for child in get_children():
		if child.get_script().get_global_name() == state_class_name:
			active_state = child
			move_child(active_state, 0)
			break
	active_state.enter()


## Connects a given callable to every singal of the matching name.
# This assumes all signals which relate to the same behavior on the parent must share a name.
# But should it allow simpler _ready code in the parent of this node.
func connect_to_all_states(callable : Callable, signal_name : String) -> void:
	for child_state in get_children():
		for signal_definition in child_state.get_signal_list():
			if signal_definition["name"] == signal_name:
				child_state.connect(signal_name, callable)


## Sets the 'parent' value of the states to the given node.
func setup(parent_node : Node) -> void:
	for child_state in get_children():
		child_state.parent = parent_node
	active_state.enter()
