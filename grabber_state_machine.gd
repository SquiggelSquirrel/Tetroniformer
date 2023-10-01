extends StateMachine


func get_grabber() -> Grabber:
	return get_parent() as Grabber
