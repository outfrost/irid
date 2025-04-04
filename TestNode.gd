extends Node

@onready var debug: = Irid.text_overlay.tracker(self)

func _ready() -> void:
	debug.trace(^":process_mode")
	await get_tree().create_timer(4.0).timeout
	queue_free()
