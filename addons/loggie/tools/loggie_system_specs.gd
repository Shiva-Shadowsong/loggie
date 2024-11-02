@tool

## LoggieSystemSpecs is a helper class that defines various functions on how to access data about the local machine and its specs
## and creates displayable strings out of them.
class_name LoggieSystemSpecsMsg extends LoggieMsg

## Embeds various system specs into the content of this message.
func embed_specs() -> LoggieSystemSpecsMsg:
	self.embed_system_specs()
	self.embed_localization_specs()
	self.embed_date_data().nl()
	self.embed_hardware_specs().nl()
	self.embed_video_specs().nl()
	self.embed_display_specs().nl()
	self.embed_audio_specs().nl()
	self.embed_engine_specs().nl()
	self.embed_input_specs()
	return self

## Embeds essential data about the logger into the content of this message.
func embed_essential_logger_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	self.add(loggie.msg("|\t Is in Production:").bold(), loggie.is_in_production()).nl()
	self.add(loggie.msg("|\t Terminal Mode:").bold(), LoggieEnums.TerminalMode.keys()[loggie.settings.terminal_mode]).nl()
	self.add(loggie.msg("|\t Log Level:").bold(), LoggieEnums.LogLevel.keys()[loggie.settings.log_level]).nl()
	return self

## Embeds advanced data about the logger into the content of this message.
func embed_advanced_logger_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	
	self.add(loggie.msg("|\t Is in Production:").bold(), loggie.is_in_production()).nl()
	
	var settings_dict = loggie.settings.to_dict()
	for setting_var_name : String in settings_dict.keys():
		var setting_value = settings_dict[setting_var_name]
		var content_to_print = setting_value
		
		match setting_var_name:
			"terminal_mode":
				content_to_print = LoggieEnums.TerminalMode.keys()[setting_value]
			"log_level":
				content_to_print = LoggieEnums.LogLevel.keys()[setting_value]
			"box_characters_mode":
				content_to_print = LoggieEnums.BoxCharactersMode.keys()[setting_value]

		self.add(loggie.msg("|\t", setting_var_name.capitalize(), ":").bold(), content_to_print).nl()
	
	return self

## Adds data about the user's software to the content of this message.
func embed_system_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Operating System: ").color(Color.ORANGE).add(OS.get_name()).box(4)
	self.add(header)
	return self
	
## Adds data about localization to the content of this message.
func embed_localization_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Localization: ").color(Color.ORANGE).add(OS.get_locale()).box(7)
	self.add(header)
	return self

## Adds data about the current date/time to the content of this message.
func embed_date_data() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Date").color(Color.ORANGE).box(15)
	self.add(header)
	self.add(loggie.msg("Date and time (local):").bold(), Time.get_datetime_string_from_system(false, true)).nl()
	self.add(loggie.msg("Date and time (UTC):").bold(), Time.get_datetime_string_from_system(true, true)).nl()
	self.add(loggie.msg("Date (local):").bold(), Time.get_date_string_from_system(false)).nl()
	self.add(loggie.msg("Date (UTC):").bold(), Time.get_date_string_from_system(true)).nl()
	self.add(loggie.msg("Time (local):").bold(), Time.get_time_string_from_system(false)).nl()
	self.add(loggie.msg("Time (UTC):").bold(), Time.get_time_string_from_system(true)).nl()
	self.add(loggie.msg("Timezone:").bold(), Time.get_time_zone_from_system()).nl()
	self.add(loggie.msg("UNIX time:").bold(), Time.get_unix_time_from_system()).nl()
	return self

## Adds data about the user's hardware to the content of this message.
func embed_hardware_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Hardware").color(Color.ORANGE).box(13)
	self.add(header)
	self.add(loggie.msg("Model name:").bold(), OS.get_model_name()).nl()
	self.add(loggie.msg("Processor name:").bold(), OS.get_processor_name()).nl()
	return self

## Adds data about the video system to the content of this message.
func embed_video_specs() -> LoggieSystemSpecsMsg:
	const adapter_type_to_string = ["Other (Unknown)", "Integrated", "Discrete", "Virtual", "CPU"]
	var adapter_type_string = adapter_type_to_string[RenderingServer.get_video_adapter_type()]
	var video_adapter_driver_info = OS.get_video_adapter_driver_info()
	var loggie = get_logger()

	var header = loggie.msg("Video").color(Color.ORANGE).box(15)
	self.add(header)
	self.add(loggie.msg("Adapter name:").bold(), RenderingServer.get_video_adapter_name()).nl()
	self.add(loggie.msg("Adapter vendor:").bold(), RenderingServer.get_video_adapter_vendor()).nl()
	self.add(loggie.msg("Adapter type:").bold(), adapter_type_string).nl()
	self.add(loggie.msg("Adapter graphics API version:").bold(), RenderingServer.get_video_adapter_api_version()).nl()

	if video_adapter_driver_info.size() > 0:
		self.add(loggie.msg("Adapter driver name:").bold(), video_adapter_driver_info[0]).nl()
	if video_adapter_driver_info.size() > 1:
		self.add(loggie.msg("Adapter driver version:").bold(), video_adapter_driver_info[1]).nl()

	return self

## Adds data about the display to the content of this message.
func embed_display_specs() -> LoggieSystemSpecsMsg:
	const screen_orientation_to_string = [
		"Landscape",
		"Portrait",
		"Landscape (reverse)",
		"Portrait (reverse)",
		"Landscape (defined by sensor)",
		"Portrait (defined by sensor)",
		"Defined by sensor",
	]
	var screen_orientation_string = screen_orientation_to_string[DisplayServer.screen_get_orientation()]
	var loggie = get_logger()

	var header = loggie.msg("Display").color(Color.ORANGE).box(13)
	self.add(header)
	self.add(loggie.msg("Screen count:").bold(), DisplayServer.get_screen_count()).nl()
	self.add(loggie.msg("DPI:").bold(), DisplayServer.screen_get_dpi()).nl()
	self.add(loggie.msg("Scale factor:").bold(), DisplayServer.screen_get_scale()).nl()
	self.add(loggie.msg("Maximum scale factor:").bold(), DisplayServer.screen_get_max_scale()).nl()
	self.add(loggie.msg("Startup screen position:").bold(), DisplayServer.screen_get_position()).nl()
	self.add(loggie.msg("Startup screen size:").bold(), DisplayServer.screen_get_size()).nl()
	self.add(loggie.msg("Startup screen refresh rate:").bold(), ("%f Hz" % DisplayServer.screen_get_refresh_rate()) if DisplayServer.screen_get_refresh_rate() > 0.0 else "").nl()
	self.add(loggie.msg("Usable (safe) area rectangle:").bold(), DisplayServer.get_display_safe_area()).nl()
	self.add(loggie.msg("Screen orientation:").bold(), screen_orientation_string).nl()
	return self

## Adds data about the audio system to the content of this message.
func embed_audio_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Audio").color(Color.ORANGE).box(14)
	self.add(header)
	self.add(loggie.msg("Mix rate:").bold(), "%d Hz" % AudioServer.get_mix_rate()).nl()
	self.add(loggie.msg("Output latency:").bold(), "%f ms" % (AudioServer.get_output_latency() * 1000)).nl()
	self.add(loggie.msg("Output device list:").bold(), ", ".join(AudioServer.get_output_device_list())).nl()
	self.add(loggie.msg("Capture device list:").bold(), ", ".join(AudioServer.get_input_device_list())).nl()
	return self

## Adds data about the godot engine to the content of this message.
func embed_engine_specs() -> LoggieSystemSpecsMsg:
	var loggie = get_logger()
	var header = loggie.msg("Engine").color(Color.ORANGE).box(14)
	self.add(header)
	self.add(loggie.msg("Version:").bold(), Engine.get_version_info()["string"]).nl()
	self.add(loggie.msg("Command-line arguments:").bold(), str(OS.get_cmdline_args())).nl()
	self.add(loggie.msg("Is debug build:").bold(), OS.is_debug_build()).nl()
	self.add(loggie.msg("Filesystem is persistent:").bold(), OS.is_userfs_persistent()).nl()
	return self

## Adds data about the input device to the content of this message.
func embed_input_specs() -> LoggieSystemSpecsMsg:
	var has_virtual_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	var loggie = get_logger()

	var header = loggie.msg("Input").color(Color.ORANGE).box(14)
	self.add(header)
	self.add(loggie.msg("Device has touch screen:").bold(), DisplayServer.is_touchscreen_available()).nl()
	self.add(loggie.msg("Device has virtual keyboard:").bold(), has_virtual_keyboard).nl()

	if has_virtual_keyboard:
		self.add(loggie.msg("Virtual keyboard height:").bold(), DisplayServer.virtual_keyboard_get_height())

	return self

## Prints out a bunch of useful data about a given script.
## Useful for debugging.
func embed_script_data(script : Script):
	var loggie = get_logger()
	self.add("Script Data for:", script.get_path()).color("pink")
	self.add(":").nl()
	self.add(loggie.msg("get_class(): ").color("slate_blue").bold()).add(script.get_class()).nl()
	self.add(loggie.msg("get_global_name(): ").color("slate_blue").bold()).add(script.get_global_name()).nl()
	self.add(loggie.msg("get_base_script(): ").color("slate_blue").bold()).add(script.get_base_script().resource_path if script.get_base_script() != null else "No base script.").nl()
	self.add(loggie.msg("get_instance_base_type(): ").color("slate_blue").bold()).add(script.get_instance_base_type()).nl()
	self.add(loggie.msg("get_script_property_list(): ").color("slate_blue").bold()).add(script.get_script_property_list()).nl()
	return self
