extends GrabberState

@export var raycast: RayCast2D


func state_process(delta) -> void:
	super(delta)
	var grabber := get_grabber()
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var tetronimo := raycast.get_collider() as Tetronimo
		if tetronimo.can_grab():
			grabber.tetronimo = tetronimo
			grabber.brick_index = raycast.get_collider_shape()
			next_state = "Holding"


func state_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_released("pickup_or_drop"):
		next_state = "Idle"
