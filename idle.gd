extends PlayerState


func state_input(event: InputEvent) -> void:
	super(event)
	if (event.is_action_pressed("move_left")
			or event.is_action_pressed("move_right")):
		next_state = "Running"
	elif event.is_action_pressed("jump"):
		next_state = "Jumping"


func enter_state() -> void:
	super()
	get_player().velocity = Vector2.ZERO


func state_process(delta: float) -> void:
	super(delta)
	var player := get_player()
	var collision := player.move_and_collide(Vector2.DOWN, true)
	if collision == null:
		next_state = "Falling"
