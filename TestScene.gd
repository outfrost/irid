extends Node2D

@onready var debug: = Irid.text_overlay.tracker(self)

func _ready() -> void:
	debug.trace(^":transform")

func _process(delta: float) -> void:
	debug.display(Performance.get_monitor(Performance.TIME_FPS))
