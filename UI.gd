extends CenterContainer


func _ready():
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()


func level_complete():
	$PanelContainer/VBoxContainer/Title.hide()
	$PanelContainer/VBoxContainer/Congratulations.show()
	$PanelContainer/VBoxContainer/Buttons/Start.hide()
	$PanelContainer/VBoxContainer/Buttons/Continue.hide()
	$PanelContainer/VBoxContainer/Buttons/Restart.hide()
	$PanelContainer/VBoxContainer/Buttons/PlayAgain.show()


func _on_start_pressed():
	hide()
	get_tree().paused = false
	$PanelContainer/VBoxContainer/Buttons/Start.hide()
	$PanelContainer/VBoxContainer/Buttons/Continue.show()
	$PanelContainer/VBoxContainer/Buttons/Restart.show()


func _on_restart_pressed():
	get_parent().restart()
	hide()
	get_tree().paused = false


func _on_continue_pressed():
	hide()
	get_tree().paused = false


func _on_play_again_pressed():
	$PanelContainer/VBoxContainer/Title.show()
	$PanelContainer/VBoxContainer/Congratulations.hide()
	
	$PanelContainer/VBoxContainer/Buttons/Continue.show()
	$PanelContainer/VBoxContainer/Buttons/Restart.show()
	$PanelContainer/VBoxContainer/Buttons/PlayAgain.hide()
	
	get_parent().restart()
	hide()
	get_tree().paused = false


func _on_visibility_changed() -> void:
	if ! visible:
		return
	for button in $PanelContainer/VBoxContainer/Buttons.get_children():
		if button.visible:
			button.grab_focus()
			return
