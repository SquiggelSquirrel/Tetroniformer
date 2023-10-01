extends TetronimoState

const DOWN = Vector2.DOWN * 24
var is_active := false


func enter_state() -> void:
	super()
	$Timer.start(0.0)
	is_active = true


func exit_state() -> void:
	super()
	$Timer.stop()
	is_active = false


func _on_timer_timeout() -> void:
	if ! is_active:
		return
	var tetronimo := get_tetronimo()
	await push_player_aside()
	var collision := tetronimo.move_and_collide(DOWN, false, 0.0)
	tetronimo.position = tetronimo.position.snapped(tetronimo.GRID_SIZE)
	if collision == null:
		return
	var collider := collision.get_collider()
	if ! collider is Tetronimo:
		next_state = "Rest"
		return
	if ! collider.is_falling():
		next_state = "Rest"


func push_player_aside() -> void:
	var tetronimo := get_tetronimo()
	var test_collision := tetronimo.move_and_collide(DOWN, true, 0.0)
	if ! test_collision is KinematicCollision2D:
		return
	
	var player := test_collision.get_collider() as Player
	if player == null:
		return
	
	if player.can_push_down():
		player.push_down()
	elif player_snapped_is_underneath(player):
		tetronimo.player_crushed.emit()
	else:
		player.grid_snap()
	
	await get_tree().process_frame


func player_snapped_is_underneath(player: Player) -> bool:
	var tetronimo := get_tetronimo()
	var player_cell := player.get_cell()
	for brick in tetronimo.get_bricks():
		var underneath = brick.get_cell() + Vector2i.DOWN
		if player_cell == underneath:
			return true
	return false
