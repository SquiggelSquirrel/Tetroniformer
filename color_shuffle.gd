@tool
extends Node

var hues := [] as Array[int]

func get_next_hue() -> int:
	if hues.size() == 0:
		for i in range(0, 16):
			hues.append(i)
		hues.shuffle()
	return hues.pop_front()
