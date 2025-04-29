extends Node2D

@onready var debug: = Irid.text_overlay.tracker(self)

func _ready() -> void:
	debug.trace(^":transform")

func _process(_delta: float) -> void:
	#debug.display(Performance.get_monitor(Performance.TIME_FPS))
	Irid.text_overlay.display(Performance.get_monitor(Performance.TIME_FPS))
	Irid.text_overlay.display(Color.LIGHT_GREEN)
	Irid.text_overlay.display(Basis.from_euler(Vector3(TAU * 0.0625, TAU * 0.125, 0.0)))
	Irid.text_overlay.display("bread")
