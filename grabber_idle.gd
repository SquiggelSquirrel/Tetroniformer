extends GrabberState

@export var effect: Node2D


func state_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("pickup_or_drop"):
		var facing: int = get_grabber().get_parent().facing
		get_grabber().set_facing(facing)
		if facing > 0:
			effect.rotation = 0
		else:
			effect.rotation = PI
		next_state = "Active"


func enter_state() -> void:
	super()
	effect.hide()


func exit_state() -> void:
	super()
	effect.show()
