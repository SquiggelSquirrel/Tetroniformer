extends PlayerState


func state_process(delta: float) -> void:
	super(delta)
	
	var player := get_player()
	player.velocity.y += player.gravity * delta
	
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction * player.facing == -1:
		player.set_facing(int(direction))
	
	player.velocity.x = lerp(
			player.velocity.x,
			direction * player.SPEED,
			clampf(delta * player.HANDLING, 0.0, 1.0))

	player.move_and_slide()
	
	if player.is_on_floor():
		if abs(player.velocity.x) < player.CUTOFF_SPEED:
			next_state = "Idle"
		else:
			next_state = "Running"
