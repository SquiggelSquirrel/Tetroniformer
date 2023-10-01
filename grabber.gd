class_name Grabber
extends Node2D

@export var grid: Grid
@export var target_offset: Vector2i
var tetronimo: Tetronimo
var brick_index: int
var facing: int = 1


func set_facing(new_facing: int) -> void:
	facing = new_facing
	$Raycast.target_position.x = 24 * facing


func get_target_cell() -> Vector2i:
	return get_parent().get_cell() + Vector2i(
			target_offset.x * facing, target_offset.y)


func release() -> void:
	$StateMachine.switch_state("Idle")
