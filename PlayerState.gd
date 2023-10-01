class_name PlayerState
extends State


func get_player() -> Player:
	return get_parent().get_player() as Player
