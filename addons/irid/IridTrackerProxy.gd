class_name IridTrackerProxy
extends RefCounted

var _tracker: IridTracker
var _visible_in_release: bool = false

func _init(tracker: IridTracker, visible_in_release: bool) -> void:
	_tracker = tracker
	_visible_in_release = visible_in_release

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		Irid.text_overlay._drop_tracker(_tracker)

func trace(property: NodePath) -> IridTrackerProxy:
	if Irid.text_overlay._release_mode && !_visible_in_release:
		return self
	if property.is_empty():
		push_error("missing property path")
		return self
	_tracker.props.append(property.get_as_property_path())
	return self

func display(v: Variant) -> IridTrackerProxy:
	if Irid.text_overlay._release_mode && !_visible_in_release:
		return self

	var msg: String
	if Irid.show_calling_function:
		var stack_frame = get_stack()[1]
		msg = "%s:%d :: %s" % [
			stack_frame.function,
			stack_frame.line,
			Irid.text_overlay._str(v),
		]
	else:
		msg = "%s" % Irid.text_overlay._str(v)

	if Engine.is_in_physics_frame():
		_tracker.physics_msgs.append(msg)
	else:
		_tracker.msgs.append(msg)

	return self
