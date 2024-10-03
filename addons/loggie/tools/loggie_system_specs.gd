@tool

## LoggieSystemSpecs is a helper class that defines various functions on how to access data about the local machine and its specs
## and creates displayable strings out of them.
class_name LoggieSystemSpecsMsg extends LoggieMsg

## Embeds various system specs into the content of this message.
func embed_specs() -> LoggieSystemSpecsMsg:
	self.embed_system_specs()
	self.embed_localization_specs()
	self.embed_date_data().nl().nl()
	self.embed_hardware_specs().nl()
	self.embed_video_specs().nl()
	self.embed_display_specs().nl()
	self.embed_audio_specs().nl()
	self.embed_engine_specs().nl()
	self.embed_input_specs()
	return self

## Adds data about the user's software to the content of this message.
func embed_system_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Operating System:[/color] {os}".format({"os": OS.get_name()})).box(4)
	self.merge(header)
	return self
	
## Adds data about localization to the content of this message.
func embed_localization_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Localization:[/color] {localization}".format({
		"localization" : OS.get_locale()
	})).box(7)
	self.merge(header)
	return self

## Adds data about the current date/time to the content of this message.
func embed_date_data() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Date[/color]").box(15)
	self.merge(header)
	self.add("[b]Date and time (local):[/b]", Time.get_datetime_string_from_system(false, true)).nl()
	self.add("[b]Date and time (UTC):[/b]", Time.get_datetime_string_from_system(true, true)).nl()
	self.add("[b]Date and time (UTC):[/b]", Time.get_datetime_string_from_system(true, true)).nl()
	self.add("[b]Date (local):[/b]", Time.get_date_string_from_system(false)).nl()
	self.add("[b]Date (UTC):[/b]", Time.get_date_string_from_system(true)).nl()
	self.add("[b]Time (local):[/b]", Time.get_time_string_from_system(false)).nl()
	self.add("[b]Time (UTC):[/b]", Time.get_time_string_from_system(true)).nl()
	self.add("[b]Timezone:[/b]", Time.get_time_zone_from_system()).nl()
	self.add("[b]UNIX time:[/b]", Time.get_unix_time_from_system())
	return self

## Adds data about the user's hardware to the content of this message.
func embed_hardware_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Hardware[/color]").box(13)
	self.merge(header)
	self.add("[b]Model name:[/b]", OS.get_model_name()).nl()
	self.add("[b]Processor name:[/b]", OS.get_processor_name()).nl()
	return self

## Adds data about the video system to the content of this message.
func embed_video_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Video[/color]").box(14)
	self.merge(header)
	self.add("[b]Adapter name:[/b]", RenderingServer.get_video_adapter_name()).nl()
	self.add("[b]Adapter vendor:[/b]", RenderingServer.get_video_adapter_vendor()).nl()
	self.add("[b]Adapter type:[/b]", [
		"Other (Unknown)",
		"Integrated",
		"Discrete",
		"Virtual",
		"CPU",
	][RenderingServer.get_video_adapter_type()]).nl()
	self.add("[b]Adapter graphics API version:[/b]", RenderingServer.get_video_adapter_api_version()).nl()

	var video_adapter_driver_info = OS.get_video_adapter_driver_info()
	if video_adapter_driver_info.size() > 0:
		self.add("[b]Adapter driver name:[/b]", video_adapter_driver_info[0]).nl()
	if video_adapter_driver_info.size() > 1:
		self.add("[b]Adapter driver version:[/b]", video_adapter_driver_info[1]).nl()
	return self

## Adds data about the display to the content of this message.
func embed_display_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Display[/color]").box(13)
	self.merge(header)
	self.add("[b]Screen count:[/b]", DisplayServer.get_screen_count()).nl()
	self.add("[b]DPI:[/b]", DisplayServer.screen_get_dpi()).nl()
	self.add("[b]Scale factor:[/b]", DisplayServer.screen_get_scale()).nl()
	self.add("[b]Maximum scale factor:[/b]", DisplayServer.screen_get_max_scale()).nl()
	self.add("[b]Startup screen position:[/b]", DisplayServer.screen_get_position()).nl()
	self.add("[b]Startup screen size:[/b]", DisplayServer.screen_get_size()).nl()
	self.add("[b]Startup screen refresh rate:[/b]", ("%f Hz" % DisplayServer.screen_get_refresh_rate()) if DisplayServer.screen_get_refresh_rate() > 0.0 else "").nl()
	self.add("[b]Usable (safe) area rectangle:[/b]", DisplayServer.get_display_safe_area()).nl()
	self.add("[b]Screen orientation:[/b]", [
		"Landscape",
		"Portrait",
		"Landscape (reverse)",
		"Portrait (reverse)",
		"Landscape (defined by sensor)",
		"Portrait (defined by sensor)",
		"Defined by sensor",
	][DisplayServer.screen_get_orientation()]).nl()
	return self

## Adds data about the audio system to the content of this message.
func embed_audio_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Audio[/color]").box(14)
	self.merge(header)
	self.add("[b]Mix rate:[/b]", "%d Hz" % AudioServer.get_mix_rate()).nl()
	self.add("[b]Output latency:[/b]", "%f ms" % (AudioServer.get_output_latency() * 1000)).nl()
	self.add("[b]Output device list:[/b]", ", ".join(AudioServer.get_output_device_list())).nl()
	self.add("[b]Capture device list:[/b]", ", ".join(AudioServer.get_input_device_list())).nl()
	return self

## Adds data about the godot engine to the content of this message.
func embed_engine_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Engine[/color]").box(14)
	self.merge(header)
	self.add("[b]Version:[/b]", Engine.get_version_info()["string"]).nl()
	self.add("[b]Command-line arguments:[/b]", str(OS.get_cmdline_args())).nl()
	self.add("[b]Is debug build:[/b]", OS.is_debug_build()).nl()
	self.add("[b]Filesystem is persistent:[/b]", OS.is_userfs_persistent()).nl()
	return self

## Adds data about the input device to the content of this message.
func embed_input_specs() -> LoggieSystemSpecsMsg:
	var loggie = getLogger()
	var header = loggie.msg("[color=orange]Input[/color]").box(14)
	self.merge(header)
	self.add("[b]Device has touch screen:[/b]", DisplayServer.is_touchscreen_available()).nl()
	var has_virtual_keyboard = DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD)
	self.add("[b]Device has virtual keyboard:[/b]", has_virtual_keyboard).nl()
	if has_virtual_keyboard:
		self.add("[b]Virtual keyboard height:[/b]", DisplayServer.virtual_keyboard_get_height())
	return self


