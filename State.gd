class_name State
extends Node

var next_state := ""


func enter_state() -> void:
	next_state = ""


func exit_state() -> void:
	pass


func state_process(_delta: float) -> void:
	pass


func state_input(_event: InputEvent) -> void:
	pass
