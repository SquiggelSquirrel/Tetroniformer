extends PlayerState


func state_process(delta: float) -> void:
	super(delta)
	var player := get_player()
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction * player.facing == -1:
		player.set_facing(int(direction))
	
	player.velocity.x = lerp(
			player.velocity.x,
			direction * player.SPEED,
			clampf(delta * player.HANDLING, 0.0, 1.0))

	player.move_and_slide()

	if not player.is_on_floor():
		next_state = "Falling"
		return
	
	if direction == 0 and abs(player.velocity.x) < player.CUTOFF_SPEED:
		next_state = "Idle"


func state_input(event: InputEvent) -> void:
	super(event)
	if event.is_action_pressed("jump"):
		next_state = "Jumping"


func enter_state() -> void:
	super()
	var player = get_player()
	player.velocity.y = 0.0
