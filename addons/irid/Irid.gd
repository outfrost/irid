extends Node

const TextOverlay: = preload("res://addons/irid/TextOverlay.gd")

@onready var text_overlay: TextOverlay = %TextOverlay

var show_source_script: bool = true
var show_calling_function: bool = true
