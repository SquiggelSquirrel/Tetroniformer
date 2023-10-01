class_name Player
extends CharacterBody2D


const SPEED: float = 300.0
const CUTOFF_SPEED: float = 20.0
const HANDLING: float = 4.0
const JUMP_VELOCITY: float = -400.0
const GRID_SIZE := Vector2(24,24)
const DOWN = Vector2.DOWN * 24

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing := 1

var is_grabbing := false
var grabbed_tetronimo: Tetronimo
var grabbed_brick_index: int


func _process(_delta: float) -> void:
	if $AntiFlyingMachine.is_colliding() or $AntiFlyingMachine2.is_colliding():
		print("Anti-flying machine triggered")
		$Grabber.release()


func crush() -> void:
	$StateMachine.switch_state("Dead")
	$Grabber/StateMachine.switch_state("Dead")
	collision_layer = 0


func set_facing(new_facing: int) -> void:
	facing = new_facing
	$AnimatedSprite2D.flip_h = (facing < 0)


func grid_snap() -> void:
	position = position.snapped(GRID_SIZE)
	velocity = Vector2.ZERO


func get_cell() -> Vector2i:
	return Vector2i(position.snapped(GRID_SIZE) / GRID_SIZE)


func can_push_down() -> bool:
	var test_transform := Transform2D.IDENTITY.translated(
			position.snapped(GRID_SIZE))
	var collides := test_move(test_transform, DOWN)
	return ! collides


func push_down() -> void:
	var collision := move_and_collide(DOWN, true)
	if collision != null:
		grid_snap()
	move_and_collide(DOWN, false)
	if velocity.y < 0.0:
		velocity.y = 0.0
	var state = $StateMachine.active_state as PlayerState
	if state.name != "Falling":
		$StateMachine.switch_state("Falling")
