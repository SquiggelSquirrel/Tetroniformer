@tool
class_name Tetronimo
extends AnimatableBody2D

signal state_changed(tetronimo, new_state)
signal player_crushed

const GRID_SIZE := Vector2i(24, 24)

@export var brick_color := Color.from_hsv(0.0, 0.85, 0.8):
	set(value):
		brick_color = value
		for brick in get_bricks():
			brick.modulate = brick_color
@export var hue: int = 0:
	set(value):
		hue = value
		brick_color.h = hue / 16.0
@export_range(0, 3, 1) var editor_rotate: int = 0:
	set(new_value):
		if ! is_ready:
			await ready
		if new_value == editor_rotate:
			return
		if new_value < editor_rotate:
			new_value += 4
		var pattern = get_pattern()
		for i in range(editor_rotate, new_value):
			pattern = Tetronimo.pattern_rotate_clockwise(pattern)
		apply_pattern(
				Vector2i(position / Vector2(GRID_SIZE)),
				Vector2i.ZERO,
				pattern)
		editor_rotate = wrapi(new_value, 0, 4)
var is_ready := false


func _ready():
	for brick in get_bricks():
		brick.connect("broken", _on_brick_broken.bind(brick))
	hue = ColorShuffle.get_next_hue()
	await get_tree().process_frame
	is_ready = true


func _on_state_machine_state_changed(new_state: String) -> void:
	state_changed.emit(self, new_state)


func _on_brick_broken(broken_brick: Brick) -> void:
	resume_falling([broken_brick])
	await get_tree().process_frame
	if get_bricks().size() == 0:
		queue_free()


func resume_falling(dead_bricks: Array[Brick] = []) -> void:
	if $StateMachine.active_state.name == "Dropping":
		return
	$StateMachine.switch_state("Dropping")
	var grid := get_parent() as Grid
	for brick in get_bricks() + dead_bricks:
		var cell := brick.get_cell() as Vector2i
		var above := cell + Vector2i.UP
		var tetronimo := grid.get_cell_resting_tetronimo(above)
		if tetronimo is Tetronimo:
			tetronimo.resume_falling()


func is_falling() -> bool:
	return $StateMachine.active_state.name == "Dropping"


func can_grab() -> bool:
	var grid := get_parent() as Grid
	var cells := [] as Array[Vector2i]
	for brick in get_bricks():
		cells.append(brick.get_cell())
	for cell in cells:
		if ! grid.cell_is_empty(cell + Vector2i.UP, self):
			return false
	return true


func grab() -> void:
	$StateMachine.switch_state("Suspended")


func release() -> void:
	$StateMachine.switch_state("Dropping")


func pull_toward(brick_index: int, target_cell: Vector2i) -> void:
	if $StateMachine.active_state.name != "Suspended":
		return
	var target_position := Vector2(target_cell * GRID_SIZE)
	var brick := get_bricks()[brick_index]
	var current_position := brick.global_position - Vector2(12, 12)
	var offset := target_position - current_position
	if ! offset.is_zero_approx():
		if move_and_collide(Vector2(offset.x, 0), true) == null:
			move_and_collide(Vector2(offset.x, 0))
		if move_and_collide(Vector2(0.0, offset.y), true) == null:
			move_and_collide(Vector2(0.0, offset.y))
	position = position.snapped(GRID_SIZE)


func get_bricks() -> Array[Brick]:
	var bricks := [] as Array[Brick]
	for child in get_children():
		if child is Brick:
			bricks.append(child)
	return bricks


func get_pattern() -> Array[Vector2i]:
	var cells := [] as Array[Vector2i]
	for brick in get_bricks():
		cells.append(brick.get_cell())
	var min_x := cells[0].x
	var min_y := cells[0].y
	for i in range(1, cells.size()):
		min_x = mini(min_x, cells[i].x)
		min_y = mini(min_y, cells[i].y)
	var origin := Vector2i(min_x, min_y)
	for i in cells.size():
		cells[i] = cells[i] - origin
	return cells


func rotate_pattern(brick_index: int, facing: int) -> int:
	var anchor := get_bricks()[brick_index]
	var anchor_cell := anchor.get_cell()
	var pattern := get_pattern()
	for i in 4:
		pattern = Tetronimo.pattern_rotate_clockwise(pattern)
		var pattern_origin: Vector2i
		if facing > 0:
			pattern_origin = Tetronimo.pattern_bottom_left(pattern)
		else:
			pattern_origin = Tetronimo.pattern_bottom_right(pattern)
		if test_pattern(anchor_cell, pattern_origin, pattern):
			return apply_pattern(anchor_cell, pattern_origin, pattern)
	return brick_index


func test_pattern(
		anchor_cell: Vector2i,
		pattern_origin: Vector2i,
		pattern: Array[Vector2i]) -> bool:
	var grid = get_parent() as Grid
	for cell in pattern:
		var global_cell := anchor_cell + cell - pattern_origin
		if ! grid.cell_is_empty(global_cell, self):
			return false
	return true


func apply_pattern(
		anchor_cell: Vector2i,
		pattern_origin: Vector2i,
		pattern: Array[Vector2i]) -> int:
	var grid := get_parent() as Grid
	position = grid.map_to_local(anchor_cell) - GRID_SIZE * 0.5
	position = position.snapped(GRID_SIZE)
	var bricks := get_bricks()
	var anchor_brick_index: int
	for i in pattern.size():
		bricks[i].position = grid.map_to_local(
				pattern[i] - pattern_origin)
		if pattern[i] == pattern_origin:
			anchor_brick_index = i
	return anchor_brick_index


static func pattern_bottom_left(cells: Array[Vector2i]) -> Vector2i:
	var bottom_left := cells[0]
	for i in range(1, cells.size()):
		if cells[i].y > bottom_left.y:
			bottom_left = cells[i]
		elif cells[i].y == bottom_left.y and cells[i].x < bottom_left.x:
			bottom_left = cells[i]
	return bottom_left


static func pattern_bottom_right(cells: Array[Vector2i]) -> Vector2i:
	var bottom_right := cells[0]
	for i in range(1, cells.size()):
		if cells[i].y > bottom_right.y:
			bottom_right = cells[i]
		elif cells[i].y == bottom_right.y and cells[i].x > bottom_right.x:
			bottom_right = cells[i]
	return bottom_right


static func pattern_rotate_clockwise(cells: Array[Vector2i]) -> Array[Vector2i]:
	cells = pattern_flip_y(cells)
	cells = pattern_transpose(cells)
	return cells


static func pattern_flip_y(cells: Array[Vector2i]) -> Array[Vector2i]:
	var max_y := cells[0].y
	for i in range(1, cells.size()):
		max_y = maxi(max_y, cells[i].y)
	for i in cells.size():
		cells[i].y = max_y - cells[i].y
	return cells


static func pattern_transpose(cells: Array[Vector2i]) -> Array[Vector2i]:
	for i in cells.size():
		cells[i] = Vector2i(cells[i].y, cells[i].x)
	return cells
