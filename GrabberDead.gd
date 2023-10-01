extends GrabberState

@export var effect: Node2D


func enter_state() -> void:
	super()
	effect.hide()
