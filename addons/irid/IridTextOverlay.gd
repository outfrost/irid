class_name IridTextOverlay
extends Node

@onready var _label: RichTextLabel = $DebugLabel
@onready var _release_mode: bool = !OS.has_feature("debug")

var _buffer: String = ""
var _trackers: Array[IridTracker] = []

func _ready():
	_label.text = ""

	var font_file_path = ProjectSettings.get_setting_with_override("plugins/irid/text_overlay_font")
	if !font_file_path || !(font_file_path is String):
		push_error("Missing or invalid project setting 'plugins/irid/text_overlay_font'.")
		return
	var font: = load(font_file_path) as Font
	if !font:
		push_error("'%s' is not a valid Font resource file. Please check your project settings." % font_file_path)
		return
	_label.add_theme_font_override("normal_font", font)

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
	_process_trackers()
	_label.text = _buffer
	_buffer = ""

func _physics_process(delta: float) -> void:
	_clear_tracker_physics_msgs()

func tracker(node: Node) -> IridTrackerProxy:
	var tracker = IridTracker.new(node)
	if !_release_mode:
		_trackers.append(tracker)
	return IridTrackerProxy.new(tracker, false)

func public_tracker(node: Node) -> IridTrackerProxy:
	var tracker = IridTracker.new(node)
	_trackers.append(tracker)
	return IridTrackerProxy.new(tracker, true)

func display(v: Variant) -> void:
	if _release_mode:
		return
	_buffer += _str(v) + "\n"

func display_public(v: Variant) -> void:
	_buffer += _str(v) + "\n"

func _process_trackers() -> void:
	for tracker in _trackers:
		_buffer += "[color=#%s][%s]\n" % [tracker.color.to_html(), tracker.node.name]
		var one: = false
		for prop in tracker.props:
			if one:
				_buffer += ", "
			else:
				_buffer += "    "
			var prop_name: StringName = prop.get_concatenated_subnames()
			_buffer += "%s: %s" % [ prop_name, _str(tracker.node.get(prop_name)) ]
			one = true
		if one:
			_buffer += "\n"
		for msg in tracker.msgs:
			_buffer += "    %s\n" % msg
		tracker.msgs.clear()
		for msg in tracker.physics_msgs:
			_buffer += "    %s\n" % msg
		_buffer += "[/color]"

func _clear_tracker_physics_msgs() -> void:
	for tracker in _trackers:
		tracker.physics_msgs.clear()

func _drop_tracker(tracker: IridTracker) -> void:
	_trackers.erase(tracker)

func _str(v: Variant) -> String:
	match typeof(v):
		TYPE_BOOL:
			return " true" if v else "false"
		TYPE_INT:
			return "%3d" % v
		TYPE_FLOAT:
			return "%7.4f" % v
		TYPE_VECTOR2, TYPE_VECTOR3, TYPE_VECTOR4:
			return "%7.4v" % v
		TYPE_VECTOR2I, TYPE_VECTOR3I, TYPE_VECTOR4I:
			return "%3.v" % v
		TYPE_RECT2, TYPE_AABB:
			return "(pos: %7.4v, size: %7.4v)" % [v.position, v.size]
		TYPE_RECT2I:
			return "(pos: %3.v, size: %3.v)" % [v.position, v.size]
		TYPE_TRANSFORM2D:
			return "(pos: %7.4v, rot: %7.2f°, scl: %7.4v, skew: %7.2f°)" % [
				v.origin,
				rad_to_deg(v.get_rotation()),
				v.get_scale(),
				rad_to_deg(v.get_skew()),
			]
		TYPE_PLANE:
			return "(nrm: %7.4v, dist: %7.4f)" % [v.normal, v.d]
		TYPE_QUATERNION:
			return "(%7.4f, %7.4f, %7.4f, %7.4f)" % [v.x, v.y, v.z, v.w]
		TYPE_BASIS:
			var euler: Vector3 = v.get_euler()
			return "(rot: (%7.2f°, %7.2f°, %7.2f°), scl: %7.4v)" % [
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.get_scale(),
			]
		TYPE_TRANSFORM3D:
			var euler: Vector3 = v.basis.get_euler()
			return "(pos: %7.4v, rot: (%7.2f°, %7.2f°, %7.2f°), scl: %7.4v)" % [
				v.origin,
				rad_to_deg(euler.x),
				rad_to_deg(euler.y),
				rad_to_deg(euler.z),
				v.basis.get_scale(),
			]
		TYPE_PROJECTION:
			return "(c0: %7.4v, c1: %7.4v, c2: %7.4v, c3: %7.4v)" % [v.x, v.y, v.z, v.w]
		TYPE_COLOR:
			var hex: String = v.to_html()
			return "[color=#%s]■[/color] (r: %6.4f, g: %6.4f, b: %6.4f, a: %6.4f, hex: #%s)" % [
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
