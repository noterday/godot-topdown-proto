# Root of the entire game. Processes the core game logic through a state machine.
#
# The game states determine what scenes are instanced, 
# what menus are drawned, which nodes process and take inputs, etc.
#
# The states are stored in an array, with only the topmost one being processed each frame.
# This allows gameplay to be stopped by a menu, which gets stopped by a sub-menu, and so forth.
extends Node2D


# Node References
@onready var Player = $Player


# Variables
var state_stack := []


# Game initialization
func _ready():
	add_state(StartState) # A first state is loaded into the state machine
	Player.CollisionHandler.current_map = $World/TileMap # This should be done by a map loading autoload or something


# Called every frame. Calls the active (topmost) state's processing function
func _process(delta):
	if state_stack:
		state_stack[-1]._process(delta)
	else: # End the game when no states are left
		get_tree().quit()


# Adds a state to the stack and initializes it
#
# This function should be called inside of states with the formulation :
# 	"await main.add_state(STATE_NAME).finished"
# This will pause the execution of the function, let the new state run until finished,
# at which point the 'finished' signal will snap execution back to the 'await' line.
func add_state(state_class):
	state_stack.append(state_class.new(self))
	state_stack[-1]._enter()
	return state_stack[-1]


# Unhandled inputs are sent to be handled by the active state
# Using _unhandled_input insures GUI nodes can process input with priority
func _unhandled_input(event):
	if state_stack:
		state_stack[-1]._unhandled_input(event)


# Abstract class for a game state.
# A state can do _process and _unhandled_input functions for the main node
class GameState:
	signal finished
	
	var main : Node2D
	func _init(_main):
		self.main = _main
	
	# Abstract - Does subclass specific initialization
	func _enter() -> void:
		pass
	
	# Abstract - Runs every frame
	func _process(_delta) -> void:
		pass
	
	# Abstract - Receives input not handled during a frame
	func _unhandled_input(_event) -> void:
		pass
	
	# Called to end the state and remove it from the stack
	#
	# The "finished" signal allows a caller state to 'await' it's callee state
	func _exit() -> void:
		main.pop_state()
		emit_signal("finished")


# State on the game opening. Splash screen would go there, then a transition to a main menu.
class StartState extends GameState:
	# Goes through normal steps of a turn in order : Player turn...
	func _process(_delta) -> void:
		await main.add_state(MainGameplay).finished
		_exit()


# Game state when the player is free to move and act, the main gameplay state
class MainGameplay extends GameState:
	# Calls for the player character to move according to inputs
	func _process(_delta) -> void:
		main.Player.process_inputs(_delta)
