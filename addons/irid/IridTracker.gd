class_name IridTracker
extends RefCounted

var node: Node
var color: Color
var props: Array[NodePath] = []
var msgs: Array[String] = []
var physics_msgs: Array[String] = []

var container: BoxContainer
var title_label: RichTextLabel
var props_label: RichTextLabel
var msg_label_pool: Array[RichTextLabel]
var physics_msg_label_pool: Array[RichTextLabel]

func _init(node: Node) -> void:
	self.node = node
	var h : = hash(node.get_path())
	self.color = Color.from_hsv((h & 0xff) / 256.0, 0.3 + ((h & 0xff00 >> 8) / 1200.0), 1.0, 1.0)
