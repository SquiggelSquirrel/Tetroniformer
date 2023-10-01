extends PlayerState

var timed_out := false

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
	
	if timed_out or ! Input.is_action_pressed("jump"):
		next_state = "Falling"


func enter_state():
	super()
	var player := get_player()
	player.velocity.y = 0.0
	timed_out = false
	$Timeout.start()


func exit_state():
	super()
	$Timeout.stop()


func _on_timeout_timeout():
	timed_out = true
