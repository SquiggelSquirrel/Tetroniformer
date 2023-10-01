extends PlayerState

var can_cancel := false


func enter_state():
	super()
	var player := get_player()
	player.velocity.y = player.JUMP_VELOCITY
	can_cancel = true
	$EarlyCancel.start()
	$AudioStreamPlayer2D.play()


func exit_state():
	super()
	$EarlyCancel.stop()


func state_process(delta: float) -> void:
	super(delta)
	
	if can_cancel and ! Input.is_action_pressed("jump"):
		cancel_jump()
		return
	
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
	
	if player.velocity.y > -1.0:
		next_state = "Hover"


func cancel_jump():
	var player := get_player()
	player.velocity.y = 0.0
	next_state = "Falling"


func _on_early_cancel_timeout():
	can_cancel = false
