@tool
extends EditorPlugin

const Common: = preload("res://addons/irid/Common.gd")

func _enter_tree() -> void:
	if !ProjectSettings.has_setting(Common.TEXT_OVERLAY_FONT_SETTING):
		ProjectSettings.set_setting(Common.TEXT_OVERLAY_FONT_SETTING, Common.TEXT_OVERLAY_FONT_DEFAULT)
		# no default because godot
		#ProjectSettings.set_initial_value(Common.TEXT_OVERLAY_FONT_SETTING, Common.TEXT_OVERLAY_FONT_DEFAULT)
		ProjectSettings.set_as_basic(Common.TEXT_OVERLAY_FONT_SETTING, true)
		ProjectSettings.add_property_info({
			&"name": Common.TEXT_OVERLAY_FONT_SETTING,
			&"type": TYPE_STRING,
			&"hint": PROPERTY_HINT_FILE,
			&"hint_string": "*.tres,*.res",
		})

	ProjectSettings.settings_changed.connect(_validate_project_settings)

	add_autoload_singleton("Irid", "res://addons/irid/Irid.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("Irid")

	if ProjectSettings.get_setting(Common.TEXT_OVERLAY_FONT_SETTING) == Common.TEXT_OVERLAY_FONT_DEFAULT:
		ProjectSettings.set_setting(Common.TEXT_OVERLAY_FONT_SETTING, null)

func _validate_project_settings() -> void:
	var font_file_path = ProjectSettings.get_setting_with_override(Common.TEXT_OVERLAY_FONT_SETTING)
	if !font_file_path || !(font_file_path is String):
		push_error("Missing or invalid project setting '%s'." % Common.TEXT_OVERLAY_FONT_SETTING)
	else:
		var font: = load(font_file_path) as Font
		if !font:
			push_error("'%s' is not a valid Font resource file. Please check your project settings." % font_file_path)
