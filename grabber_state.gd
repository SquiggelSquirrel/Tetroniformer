class_name GrabberState
extends State


func get_grabber() -> Grabber:
	return get_parent().get_grabber()
