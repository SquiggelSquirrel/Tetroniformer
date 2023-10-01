extends PlayerState


func enter_state():
	super()
	$AudioStreamPlayer2D.play()
