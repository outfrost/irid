extends Control

const Common: = preload("res://addons/irid/Common.gd")

const LABEL_SCN: PackedScene = preload("res://addons/irid/TextOverlayLabel.tscn")
const MSG_LABEL_POOL_INIT_SIZE: int = 4

var node: Node
var color: Color
var props: Array[NodePath] = []
var msgs: Array[String] = []
var physics_msgs: Array[String] = []

var title_label: RichTextLabel
var props_label: RichTextLabel
var msg_label_pool: Array[RichTextLabel]
var physics_msg_label_pool: Array[RichTextLabel]

func _setup(node: Node) -> void:
	self.node = node
	var h : = hash(node.get_path())
	self.color = Color.from_hsv((h & 0xff) / 256.0, 0.3 + ((h & 0xff00 >> 8) / 1200.0), 1.0, 1.0)

	var label: RichTextLabel = LABEL_SCN.instantiate()
	label.text = "[%s]" % node.name
	if Irid.show_source_script:
		var stack_frame = get_stack()[2]
		label.text += " [color=#bbbbbbff][%s][/color]" % stack_frame[&"source"]
	label.add_theme_color_override(&"default_color", color)
	title_label = label
	add_child(label)

	label = LABEL_SCN.instantiate()
	label.add_theme_color_override(&"default_color", color)
	props_label = label
	add_child(label)

	for i in MSG_LABEL_POOL_INIT_SIZE:
		label = LABEL_SCN.instantiate()
		label.add_theme_color_override(&"default_color", color)
		msg_label_pool.push_back(label)
		add_child(label)

	for i in MSG_LABEL_POOL_INIT_SIZE:
		label = LABEL_SCN.instantiate()
		label.add_theme_color_override(&"default_color", color)
		physics_msg_label_pool.push_back(label)
		add_child(label)

func _process(delta: float) -> void:
	var buffer: = String()
	var one: = false
	for prop in props:
		if one:
			buffer += ", "
		else:
			buffer += "    "
		var prop_name: StringName = prop.get_concatenated_subnames()
		buffer += "%s: %s" % [ prop_name, Common._str(node.get(prop_name)) ]
		one = true
	props_label.text = buffer

	var pool_grow: = msgs.size() - msg_label_pool.size()
	if pool_grow > 0:
		var child_idx: = (msg_label_pool.back() as Node).get_index()
		for i in pool_grow:
			child_idx += 1
			var label: RichTextLabel = LABEL_SCN.instantiate()
			label.add_theme_color_override(&"default_color", color)
			msg_label_pool.push_back(label)
			add_child(label)
			move_child(label, child_idx)

	for i in msg_label_pool.size():
		if i < msgs.size():
			(msg_label_pool[i] as RichTextLabel).text = "    " + msgs[i]
		else:
			(msg_label_pool[i] as RichTextLabel).text = ""
	msgs.clear()

	pool_grow = physics_msgs.size() - physics_msg_label_pool.size()
	if pool_grow > 0:
		for i in pool_grow:
			var label: RichTextLabel = LABEL_SCN.instantiate()
			label.add_theme_color_override(&"default_color", color)
			physics_msg_label_pool.push_back(label)
			add_child(label)

	for i in physics_msg_label_pool.size():
		if i < physics_msgs.size():
			(physics_msg_label_pool[i] as RichTextLabel).text = "    " + physics_msgs[i]
		else:
			(physics_msg_label_pool[i] as RichTextLabel).text = ""

func _physics_process(delta: float) -> void:
	physics_msgs.clear()
