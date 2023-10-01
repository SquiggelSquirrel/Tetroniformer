extends Node

var start_scene := preload("res://stage_1.tscn")


func _ready():
	$TileMap.level_complete.connect(_on_level_complete)


func restart():
	var stage = $TileMap
	remove_child(stage)
	stage.call_deferred("free")
	var reloaded_stage_scene = load("res://stage_1.tscn")
	var reloaded_stage = reloaded_stage_scene.instantiate()
	add_child(reloaded_stage)
	move_child(reloaded_stage, 0)
	reloaded_stage.level_complete.connect(_on_level_complete)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		get_tree().paused = true
		$Controls.show()


func _on_level_complete() -> void:
	$Controls.level_complete()
	$Controls.show()
	get_tree().paused = true
