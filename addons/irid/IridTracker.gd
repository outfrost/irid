class_name IridTracker
extends RefCounted

var node: Node
var color: Color
var props: Array[NodePath] = []
var msgs: Array[String] = []
var physics_msgs: Array[String] = []

func _init(node: Node) -> void:
	self.node = node
	var h : = hash(node.get_path())
	self.color = Color.from_hsv((h & 0xff) / 256.0, 0.3 + ((h & 0xff00 >> 8) / 1200.0), 1.0, 1.0)
