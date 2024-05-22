@tool
extends EditorPlugin

const TEXT_OVERLAY_DEFAULT_FONT: String = "res://addons/irid/font/system/monospace_medium.tres"

func _enter_tree() -> void:
	if !(ProjectSettings.get_setting("plugins/irid/text_overlay_font") is String):
		ProjectSettings.set_setting("plugins/irid/text_overlay_font", TEXT_OVERLAY_DEFAULT_FONT)
		ProjectSettings.set_initial_value("plugins/irid/text_overlay_font", TEXT_OVERLAY_DEFAULT_FONT)
		ProjectSettings.set_as_basic("plugins/irid/text_overlay_font", true)
		ProjectSettings.add_property_info({
			"name": "plugins/irid/text_overlay_font",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres,*.res",
		})

	ProjectSettings.settings_changed.connect(_validate_project_settings)

	add_autoload_singleton("Irid", "res://addons/irid/Irid.tscn")

func _exit_tree() -> void:
	remove_autoload_singleton("Irid")

	if ProjectSettings.get_setting("plugins/irid/text_overlay_font") == TEXT_OVERLAY_DEFAULT_FONT:
		ProjectSettings.set_setting("plugins/irid/text_overlay_font", null)

func _validate_project_settings() -> void:
	var font_file_path = ProjectSettings.get_setting_with_override("plugins/irid/text_overlay_font")
	if !font_file_path || !(font_file_path is String):
		push_error("Missing or invalid project setting 'plugins/irid/text_overlay_font'.")
	else:
		var font: = load(font_file_path) as Font
		if !font:
			push_error("'%s' is not a valid Font resource file. Please check your project settings." % font_file_path)
