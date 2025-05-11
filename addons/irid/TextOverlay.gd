extends Node

const Common: = preload("res://addons/irid/Common.gd")
const TextTracker: = preload("res://addons/irid/TextTracker.gd")
const TextTrackerProxy: = preload("res://addons/irid/TextTrackerProxy.gd")

const TRACKER_SCN: PackedScene = preload("res://addons/irid/TextTracker.tscn")
const LABEL_SCN: PackedScene = preload("res://addons/irid/TextOverlayLabel.tscn")
const MSG_LABEL_POOL_INIT_SIZE: int = 16

@onready var _outer_container: BoxContainer = %OuterContainer
@onready var _msg_container: BoxContainer = %MsgContainer
@onready var _trackers_container: BoxContainer = %TrackersContainer
@onready var _release_mode: bool = !OS.has_feature("debug")

var _msgs: Array[String] = []
var _msg_label_pool: Array[RichTextLabel] = []
var _trackers: Array[TextTracker] = []

func _ready():
	for i in MSG_LABEL_POOL_INIT_SIZE:
		var label: RichTextLabel = LABEL_SCN.instantiate()
		_msg_label_pool.push_back(label)
		_msg_container.add_child(label)

	var font_file_path = ProjectSettings.get_setting_with_override(Common.TEXT_OVERLAY_FONT_SETTING)
	if !font_file_path || !(font_file_path is String):
		push_error("Missing or invalid project setting '%s'." % Common.TEXT_OVERLAY_FONT_SETTING)
		return
	var font: = load(font_file_path) as Font
	if !font:
		push_error("'%s' is not a valid Font resource file. Please check your project settings." % font_file_path)
		return
	_outer_container.theme = _outer_container.theme.duplicate()
	_outer_container.theme.set_font(&"normal_font", &"RichTextLabel", font)

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

func tracker(node: Node) -> TextTrackerProxy:
	var tracker = TRACKER_SCN.instantiate()
	if !_release_mode:
		tracker._setup(node)
		_trackers_container.add_child(tracker)
	_trackers.append(tracker)
	return TextTrackerProxy.new(tracker, false)

func public_tracker(node: Node) -> TextTrackerProxy:
	var tracker = TRACKER_SCN.instantiate()
	tracker._setup(node)
	_trackers_container.add_child(tracker)
	_trackers.append(tracker)
	return TextTrackerProxy.new(tracker, true)

func display(v: Variant) -> void:
	if _release_mode:
		return
	_msgs.push_back(Common._str(v))

func display_public(v: Variant) -> void:
	_msgs.push_back(Common._str(v))

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

func _drop_tracker(tracker: TextTracker) -> void:
	if is_instance_valid(tracker):
		tracker.queue_free()
	_trackers.erase(tracker)
