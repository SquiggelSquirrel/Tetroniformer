extends GrabberState

@export var effect: Node2D


func enter_state() -> void:
	super()
	get_grabber().tetronimo.grab()


func exit_state() -> void:
	super()
	get_grabber().tetronimo.release()


func state_input(event: InputEvent) -> void:
	super(event)
	var grabber := get_grabber()
	if event.is_action_pressed("pickup_or_drop"):
		next_state = "Idle"
	if event.is_action_pressed("rotate"):
		grabber.brick_index = await grabber.tetronimo.rotate_pattern(
				grabber.brick_index, grabber.facing)


func state_process(delta: float) -> void:
	super(delta)
	var grabber := get_grabber()
	var target_cell := grabber.get_target_cell()
	grabber.tetronimo.pull_toward(grabber.brick_index, target_cell)
	effect.look_at(grabber.grid.map_to_local(target_cell))
