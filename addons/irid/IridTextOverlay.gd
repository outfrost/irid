class_name IridTextOverlay
extends Node

const MSG_CONTAINER_SCN: PackedScene = preload("res://addons/irid/MsgContainer.tscn")
const LABEL_SCN: PackedScene = preload("res://addons/irid/TextOverlayLabel.tscn")
const MSG_LABEL_POOL_INIT_SIZE: int = 16
const TRACKER_LABEL_POOL_INIT_SIZE: int = 4

@onready var _outer_container: BoxContainer = %OuterContainer
@onready var _msg_container: BoxContainer = %MsgContainer
@onready var _trackers_container: BoxContainer = %TrackersContainer
@onready var _release_mode: bool = !OS.has_feature("debug")

var _msgs: Array[String] = []
var _msg_label_pool: Array[RichTextLabel] = []
var _trackers: Array[IridTracker] = []

func _ready():
	for i in MSG_LABEL_POOL_INIT_SIZE:
		var label: RichTextLabel = LABEL_SCN.instantiate()
		_msg_label_pool.push_back(label)
		_msg_container.add_child(label)

	var font_file_path = ProjectSettings.get_setting_with_override("plugins/irid/text_overlay_font")
	if !font_file_path || !(font_file_path is String):
		push_error("Missing or invalid project setting 'plugins/irid/text_overlay_font'.")
		return
	var font: = load(font_file_path) as Font
	if !font:
		push_error("'%s' is not a valid Font resource file. Please check your project settings." % font_file_path)
		return
	_outer_container.add_theme_font_override("normal_font", font)

	#print(_str(Rect2(10.0, 20.0, 100.0, 200.0)))
	#print(_str(Rect2i(8, 16, 128, 256)))
	#print(_str(Transform2D.IDENTITY))
	#print(_str(Transform3D.IDENTITY))
	#print(_str(Plane.PLANE_XZ))
	#print(_str(Quaternion.from_euler(Vector3(0.49, TAU * 0.52, TAU * 0.71))))
	#print(_str(AABB(Vector3(1.0, 2.0, 3.0), Vector3(5.0, 5.0, 6.0))))
	#print(_str(Basis.IDENTITY))
	#print(_str(Projection.IDENTITY))
	#print(_str(Color.INDIGO))

func _process(_delta):
	_process_msgs()
	_process_trackers()

func _physics_process(delta: float) -> void:
	_clear_tracker_physics_msgs()

func tracker(node: Node) -> IridTrackerProxy:
	var tracker = IridTracker.new(node)
	if !_release_mode:
		_setup_tracker_labels(tracker)
		_trackers.append(tracker)
	return IridTrackerProxy.new(tracker, false)

func public_tracker(node: Node) -> IridTrackerProxy:
	var tracker = IridTracker.new(node)
	_setup_tracker_labels(tracker)
	_trackers.append(tracker)
	return IridTrackerProxy.new(tracker, true)

func display(v: Variant) -> void:
	if _release_mode:
		return
	_msgs.push_back(_str(v))

func display_public(v: Variant) -> void:
	_msgs.push_back(_str(v))

func _process_msgs() -> void:
	var pool_grow: = _msgs.size() - _msg_label_pool.size()
	if pool_grow > 0:
		for i in pool_grow:
			var label: RichTextLabel = LABEL_SCN.instantiate()
			_msg_label_pool.push_back(label)
			_msg_container.add_child(label)

	for i in _msg_label_pool.size():
		if i < _msgs.size():
			(_msg_label_pool[i] as RichTextLabel).text = _msgs[i]
		else:
			(_msg_label_pool[i] as RichTextLabel).text = ""

	_msgs.clear()

func _setup_tracker_labels(tracker: IridTracker) -> void:
	var container: = MSG_CONTAINER_SCN.instantiate()
	tracker.container = container
	_trackers_container.add_child(container)

	var label: RichTextLabel = LABEL_SCN.instantiate()
	label.text = "[%s]" % tracker.node.name
	label.add_theme_color_override(&"default_color", tracker.color)
	tracker.title_label = label
	container.add_child(label)

	label = LABEL_SCN.instantiate()
	label.add_theme_color_override(&"default_color", tracker.color)
	tracker.props_label = label
	container.add_child(label)

	for i in TRACKER_LABEL_POOL_INIT_SIZE:
		label = LABEL_SCN.instantiate()
		label.add_theme_color_override(&"default_color", tracker.color)
		tracker.msg_label_pool.push_back(label)
		container.add_child(label)

	for i in TRACKER_LABEL_POOL_INIT_SIZE:
		label = LABEL_SCN.instantiate()
		label.add_theme_color_override(&"default_color", tracker.color)
		tracker.physics_msg_label_pool.push_back(label)
		container.add_child(label)

func _process_trackers() -> void:
	for tracker in _trackers:
		var buffer: = String()
		var one: = false
		for prop in tracker.props:
			if one:
				buffer += ", "
			else:
				buffer += "    "
			var prop_name: StringName = prop.get_concatenated_subnames()
			buffer += "%s: %s" % [ prop_name, _str(tracker.node.get(prop_name)) ]
			one = true
		tracker.props_label.text = buffer

		var pool_grow: = tracker.msgs.size() - tracker.msg_label_pool.size()
		if pool_grow > 0:
			var child_idx: = (tracker.msg_label_pool.back() as Node).get_index()
			for i in pool_grow:
				child_idx += 1
				var label: RichTextLabel = LABEL_SCN.instantiate()
				label.add_theme_color_override(&"default_color", tracker.color)
				tracker.msg_label_pool.push_back(label)
				tracker.container.add_child(label)
				tracker.container.move_child(label, child_idx)

		for i in tracker.msg_label_pool.size():
			if i < tracker.msgs.size():
				(tracker.msg_label_pool[i] as RichTextLabel).text = "    " + tracker.msgs[i]
			else:
				(tracker.msg_label_pool[i] as RichTextLabel).text = ""
		tracker.msgs.clear()

		pool_grow = tracker.physics_msgs.size() - tracker.physics_msg_label_pool.size()
		if pool_grow > 0:
			for i in pool_grow:
				var label: RichTextLabel = LABEL_SCN.instantiate()
				label.add_theme_color_override(&"default_color", tracker.color)
				tracker.physics_msg_label_pool.push_back(label)
				tracker.container.add_child(label)

		for i in tracker.physics_msg_label_pool.size():
			if i < tracker.physics_msgs.size():
				(tracker.physics_msg_label_pool[i] as RichTextLabel).text = "    " + tracker.physics_msgs[i]
			else:
				(tracker.physics_msg_label_pool[i] as RichTextLabel).text = ""

func _clear_tracker_physics_msgs() -> void:
	for tracker in _trackers:
		tracker.physics_msgs.clear()

func _drop_tracker(tracker: IridTracker) -> void:
	if tracker.container:
		tracker.container.queue_free()
	_trackers.erase(tracker)

func _str(v: Variant) -> String:
	match typeof(v):
		TYPE_BOOL:
			return " true" if v else "false"
		TYPE_INT:
			return "%3d" % v
		TYPE_FLOAT:
			return "%6.3f" % v
		TYPE_STRING:
			return v as String
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			return "%6.3v" % v
		TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
			return "%3.v" % v
		TYPE_RECT2, TYPE_AABB:
			return "(pos: %6.3v, size: %6.3v)" % [v.position, v.size]
		TYPE_RECT2I:
			return "(pos: %3.v, size: %3.v)" % [v.position, v.size]
		TYPE_TRANSFORM2D:
			return "(pos: %6.3v, rot: %6.1f°, scl: %6.3v, skew: %6.1f°)" % [
				v.origin,
				rad_to_deg(v.get_rotation()),
				v.get_scale(),
				rad_to_deg(v.get_skew()),
			]
		TYPE_PLANE:
			return "(nrm: %6.3v, dist: %6.3f)" % [v.normal, v.d]
		TYPE_QUATERNION:
			return "(%6.3f, %6.3f, %6.3f, %6.3f)" % [v.x, v.y, v.z, v.w]
		TYPE_BASIS:
			var euler: Vector3 = v.get_euler()
			return "(rot: (%6.1f°, %6.1f°, %6.1f°), scl: %6.3v)" % [
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.get_scale(),
			]
		TYPE_TRANSFORM3D:
			var euler: Vector3 = v.basis.get_euler()
			return "(pos: %6.3v, rot: (%6.1f°, %6.1f°, %6.1f°), scl: %6.3v)" % [
				v.origin,
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.basis.get_scale(),
			]
		TYPE_PROJECTION:
			return "(c0: %6.3v, c1: %6.3v, c2: %6.3v, c3: %6.3v)" % [v.x, v.y, v.z, v.w]
		TYPE_COLOR:
			var hex: String = v.to_html()
			return "[color=#%s]■[/color] (r: %5.3f, g: %5.3f, b: %5.3f, a: %5.3f, hex: #%s)" % [
				hex,
				v.r,
				v.g,
				v.b,
				v.a,
				hex
			]
		#TYPE_DICTIONARY:
		#TYPE_ARRAY:
		_:
			return str(v)
