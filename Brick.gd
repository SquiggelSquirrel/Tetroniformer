@tool
class_name Brick
extends CollisionShape2D

signal broken

const GRID_SIZE := Vector2(24, 24)

var is_breaking := false


func get_cell() -> Vector2i:
	return Vector2i(global_position / GRID_SIZE)


func brick_break() -> void:
	is_breaking = true
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(emit_signal.bind("broken"))
	tween.tween_callback(queue_free)
