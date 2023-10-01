class_name TetronimoState
extends State

@export_flags_2d_physics var collision_layer: int


func get_tetronimo() -> Tetronimo:
	return get_parent().get_tetronimo() as Tetronimo


func enter_state() -> void:
	super()
	get_tetronimo().collision_layer = collision_layer
