class_name Grid
extends TileMap

signal level_complete

@export_flags_2d_physics var rest_mask : int = 0


func _ready():
	var source := tile_set.get_source(0) as TileSetAtlasSource
	var tile_data := source.get_tile_data(Vector2i(2, 0), 0)
	tile_data.set_collision_polygon_points(0, 0, [
		Vector2(-11.5, -11.5),
		Vector2(11.5, -11.5),
		Vector2(11.5, 11.5),
		Vector2(-11.5, 11.5)
	])
	for child in get_children():
		if child is Tetronimo:
			child.player_crushed.connect(_on_tetronimo_crush)
			child.state_changed.connect(_on_tetronimo_state_changed)
	get_tree().paused = true


func cell_is_empty(cellv: Vector2i, exclude: CollisionObject2D) -> bool:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.exclude = [exclude.get_rid()]
	query.position = map_to_local(cellv)
	var bricks := space.intersect_point(query)
	return bricks.size() == 0


func get_cell_resting_tetronimo(cellv: Vector2i) -> Tetronimo:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = map_to_local(cellv)
	query.collision_mask = rest_mask
	var tetronimos := space.intersect_point(query)
	if tetronimos.size() == 0:
		return null
	var tetronimo = tetronimos[0].collider
	return tetronimo


func get_cell_resting_brick(cellv: Vector2i) -> Brick:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = map_to_local(cellv)
	query.collision_mask = rest_mask
	var bricks := space.intersect_point(query)
	if bricks.size() == 0:
		return null
	var brick = bricks[0].collider.get_bricks()[bricks[0].shape]
	return brick


func _on_tetronimo_state_changed(
		tetronimo: Tetronimo, new_state: String) -> void:
	if new_state != "Rest":
		return
	await get_tree().process_frame
	_on_tetrinomimo_rest(tetronimo)


func _on_tetronimo_crush() -> void:
	$Player.crush()


func _on_tetrinomimo_rest(tetrinomino: Tetronimo) -> void:
	for brick in tetrinomino.get_bricks():
		if brick.is_breaking:
			continue
		check_row_break(brick.get_cell())


func check_row_break(cell: Vector2i) -> void:
	var y = cell.y
	var consecutive_bricks := [] as Array[Brick]
	for x in range(cell.x - 9, cell.x + 10):
		var brick := get_cell_resting_brick(Vector2(x, y))
		if brick != null and ! brick.is_breaking:
			consecutive_bricks.append(brick)
			continue
		if consecutive_bricks.size() > 9:
			break_row(consecutive_bricks)
			return
		else:
			consecutive_bricks.clear()
	if consecutive_bricks.size() > 9:
		break_row(consecutive_bricks)


func break_row(bricks: Array[Brick]) -> void:
	print("break_row")
	$RowBreak.play()
	for brick in bricks:
		brick.brick_break()


func _on_flag_body_entered(_body):
	level_complete.emit()
