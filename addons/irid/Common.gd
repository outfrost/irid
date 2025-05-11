extends RefCounted

const TEXT_OVERLAY_FONT_SETTING: StringName = &"plugins/irid/text_overlay_font"
const TEXT_OVERLAY_FONT_DEFAULT: String = "res://addons/irid/font/system/monospace_medium.tres"

static func _str(v: Variant) -> String:
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
