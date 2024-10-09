extends Control

func _ready() -> void:
	$Label.text = "Loggie {version}".format({"version": Loggie.VERSION})
	test()

func test() -> void:
	# Test outputting a box header.
	Loggie.msg("Box Header Test").color("red").box().info()
	
	# Test outputting a header, with a newline and a 30 character long horizontal separator.
	Loggie.msg("Colored Header").header().color("yellow").nl().hseparator(30).info()

	# Test all types of messages.
	Loggie.msg("Hello World").info()
	Loggie.msg("Hello", "World", "Multi", "Argument").info()
	Loggie.msg("Test error.").error()
	Loggie.msg("Test warning.").warn()
	Loggie.msg("Test notice.").notice()
	Loggie.msg("Test debug message.").debug()
	
	# Test a supported color message.
	Loggie.msg("I'm cyan.").color("cyan").info()
	
	# Test a custom colored message.
	Loggie.msg("I'm slate blue.").color(Color.SLATE_BLUE).info()
	
	# Test pretty printing a dictionary.
	var testDict = {
		"a" : "Hello",
		"b" : {
			"c" : 1,
			"d" : [1,2,3]
		},
		"c" : ["A", {"B" : "2"}, 3]
	}
	Loggie.msg(testDict).info()
	
	# Test outputting a message from an enabled custom domain.
	Loggie.set_domain_enabled("Domain1", true)
	Loggie.msg("This message is coming from an enabled domain.").domain("Domain1").info()

	# Test outputting a message from a disabled domain.
	Loggie.set_domain_enabled("Domain1", false)
	Loggie.msg("This message is coming from a disabled domain (you shouldn't be seeing this in the output).").domain("Domain1").info()

	# Test outputting a message from a different script.
	# If 'Loggie.settings.derive_and_show_class_names' is true, the name of the class should show up properly as prefix.
	var talker = LoggieTalker.new()
	talker.say("Greetings!")
	
	# Test shortcut wrappers.
	Loggie.debug("Debug wrapper test.")
	Loggie.info("Info wrapper test.")
	Loggie.notice("Notice wrapper test.")
	Loggie.warn("Warn wrapper test.")
	Loggie.error("Error wrapper test.")

func print_setting_values_from_project_settings():
	for key in LoggieSettings.project_settings.keys():
		print(key, " -> ", ProjectSettings.get_setting(key))

func print_actual_current_settings():
	print("terminal_mode => ", Loggie.settings.terminal_mode)
	print("log_level => ", Loggie.settings.log_level)
	print("show_loggie_specs => ", Loggie.settings.show_loggie_specs)
	print("show_system_specs => ", Loggie.settings.show_system_specs)
	print("output_message_domain => ", Loggie.settings.output_message_domain)
	print("print_errors_to_console => ", Loggie.settings.print_errors_to_console)
	print("print_warnings_to_console => ", Loggie.settings.print_warnings_to_console)
	print("use_print_debug_for_debug_msg => ", Loggie.settings.use_print_debug_for_debug_msg)
	print("derive_and_show_class_names => ", Loggie.settings.derive_and_show_class_names)
	print("show_timestamps => ", Loggie.settings.show_timestamps)
	print("timestamps_use_utc => ", Loggie.settings.timestamps_use_utc)
	print("format_header => ", Loggie.settings.format_header)
	print("format_domain_prefix => ", Loggie.settings.format_domain_prefix)
	print("format_error_msg => ", Loggie.settings.format_error_msg)
	print("format_warning_msg => ", Loggie.settings.format_warning_msg)
	print("format_notice_msg => ", Loggie.settings.format_notice_msg)
	print("format_info_msg => ", Loggie.settings.format_info_msg)
	print("format_debug_msg => ", Loggie.settings.format_debug_msg)
	print("h_separator_symbol => ", Loggie.settings.h_separator_symbol)
	print("box_characters_mode => ", Loggie.settings.box_characters_mode)
	print("box_symbols_compatible => ", Loggie.settings.box_symbols_compatible)
	print("box_symbols_pretty => ", Loggie.settings.box_symbols_pretty)
