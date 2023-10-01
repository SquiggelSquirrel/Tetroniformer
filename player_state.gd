class_name PlayerState
extends State


func get_player() -> Player:
	var parent = get_parent()
	assert(parent is StateMachine)
	assert(parent.has_method("get_player"))
	return get_parent().get_player() as Player
