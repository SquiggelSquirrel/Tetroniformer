class_name StateMachine
extends Node

signal state_changed(new_state)

@export var active_state: State


func _ready() -> void:
	if active_state == null:
		active_state = get_child(0)
	await get_tree().process_frame
	active_state.enter_state()


func _process(delta: float) -> void:
	active_state.state_process(delta)
	if active_state.next_state != "":
		switch_state(active_state.next_state)


func _input(event: InputEvent) -> void:
	active_state.state_input(event)
	if active_state.next_state != "":
		switch_state(active_state.next_state)


func switch_state(new_state: String) -> void:
	active_state.exit_state()
	active_state = get_node(new_state)
	active_state.enter_state()
	state_changed.emit(new_state)
