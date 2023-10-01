extends AnimatedSprite2D


func _on_state_machine_state_changed(new_state):
	play(new_state)
