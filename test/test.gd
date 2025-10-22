## This script serves as a playground for testing out Loggie features.
## It is not an actual test suite with assertions, but it can serve well
## for testing core functionality during development.
class_name LoggieTestPlayground extends Control

## Stores a duplicate of the [LoggieSettings] which are configured in [Loggie] in the moment this node becomes ready,
## so that you can modify `Loggie.settings` on the fly during this script while having a backup of the original state.
var original_settings : LoggieSettings

const SCRIPT_LOGGIE_TALKER = preload("res://test/testing_props/talkers/LoggieTalker.gd")
const SCRIPT_LOGGIE_TALKER_CHILD = preload("res://test/testing_props/talkers/LoggieTalkerChild.gd")
const SCRIPT_LOGGIE_TALKER_GRANDCHILD = preload("res://test/testing_props/talkers/LoggieTalkerGrandchild.gd")
const SCRIPT_LOGGIE_TALKER_NAMED_GRANDCHILD = preload("res://test/testing_props/talkers/LoggieTalkerNamedGrandchild.gd")
const SCRIPT_LOGGIE_TALKER_NAMED_CHILD = preload("res://test/testing_props/talkers/LoggieTalkerNamedChild.gd")

func _init() -> void:
	Loggie.msg("Test message from test.gd _init.").warn()

func _ready() -> void:
	original_settings = Loggie.settings.duplicate()
	setup_gui()
	run_tests()

	#print_setting_values_from_project_settings()
	#print_actual_current_settings()
	#print_talker_scripts_data()

	#test_all_log_level_outputs()
	#test_decors()
	#test_output_from_classes_of_various_inheritances_and_origins()
	#test_domains()
	#test_segments()
	#test_bbcode_to_markdown()
	#test_discord_channel()
	#test_slack_channel()
	#test_update_widget()

func setup_gui():
	var test_channel = load("res://test/testing_props/TestChannel.gd").new()
	Loggie.add_channel(test_channel)

	$Label.text = "Loggie {version}".format({"version": Loggie.get("version_manager").version if Loggie.get("version_manager") != null else "<?>"})
	Loggie.msg("Edit the test.tscn _ready function and uncomment the calls to features you want to test out.").italic().color(Color.GRAY).preprocessed(false).info()

func run_tests():
	print("---------------------------------------")
	print("\t\t\tTesting Started")
	print("---------------------------------------")

	# Prepare results storage.
	var results : Dictionary = {}
	for result_type in LoggieAutoTestCase.Result.values():
		results[result_type] = [] as Array[LoggieAutoTestCase]

	# Run each case and store results.
	for case : LoggieAutoTestCase in %AutoTestCases.get_children():
		Loggie.settings = case.settings
		print_rich("[i][b][color=CORNFLOWER_BLUE]Running case:[/color] [color=DARK_TURQUOISE]{caseName}[/color][/b][/i]".format({
			"caseName" : case.get_script().get_global_name(),
		}))
		case._run_timeout_counter()
		case.call_deferred("run")
		await case.finished
		results[case.result].push_back(case)

	# Account for tests that didn't run.
	var disabled_cases : Array[LoggieAutoTestCase]
	for node in %DisabledAutoTestCases.get_children():
		if node is LoggieAutoTestCase:
			disabled_cases.push_back(node)
	results[LoggieAutoTestCase.Result.DidntRun] = disabled_cases

	# Report Results.
	print_final_report(results)

func print_final_report(results : Dictionary) -> void:
	print("---------------------------------------")
	print("\t\t\tTesting Finished")
	print("---------------------------------------")

	var conclusion = ""
	var conclusion_color = "pale_green"
	var conclusion_icon = "✔️"
	var context = ""

	var failed_tests : Array[LoggieAutoTestCase] = results[LoggieAutoTestCase.Result.Fail]
	var disabled_tests : Array[LoggieAutoTestCase]  = results[LoggieAutoTestCase.Result.DidntRun]
	var timed_out_tests : Array[LoggieAutoTestCase]  = results[LoggieAutoTestCase.Result.TimedOut]
	var successful_tests : Array[LoggieAutoTestCase]  = results[LoggieAutoTestCase.Result.Success]

	var total_tests = %AutoTestCases.get_child_count()
	var total_failed_tests : int = failed_tests.size() + timed_out_tests.size()


	if disabled_tests.size() > 0:
		conclusion_color = "gold"
		conclusion_icon = "☢️"
		context += "\n\t* [color=GOLD]☢️ {amount} tests were disabled. Please move all tests from 'DisabledAutoTestCases' to 'AutoTestCases' to try a full run.[/color]".format({
			"amount": disabled_tests.size()
		})

	if total_failed_tests > 0:
		conclusion_color = "salmon"
		conclusion_icon = "❌"
		conclusion = "{amount} tests failed."
		if failed_tests.size() > 0:
			context += "\n\t* [color=SALMON]{amount} tests failed. Please debug and fix the issues that caused these tests to fail: {list}[/color]".format({
				"amount": failed_tests.size(),
				"list": failed_tests
			})
		if timed_out_tests.size() > 0:
			context += "\n\t* [color=SALMON]{amount} tests timed out. They failed to call 'success()' or 'fail()' within the allotted amount of time. Please debug and fix the issues that caused these tests to time out: {list}[/color]".format({
				"amount": timed_out_tests.size(),
				"list": timed_out_tests
			})
	else:
		if disabled_tests.size() == 0:
			context += "\t* Looks like things should be good to go!"

	conclusion = "[b][i][color={color_str}]{icon} ({amount} / {total}) tests successful.[/color][/i][/b]".format({
		"color_str": conclusion_color,
		"icon": conclusion_icon,
		"amount": successful_tests.size(),
		"total": total_tests
	})

	print_rich(conclusion)
	print_rich(context)

# -----------------------------------------
#region Tests
# -----------------------------------------

func test_all_log_level_outputs():
	# Test all types of messages.
	Loggie.msg("Test logging methods").box(25).info()
	Loggie.msg("Test error.").error()
	Loggie.msg("Test warning.").warn()
	Loggie.msg("Test notice.").notice()
	Loggie.msg("Test info").info()
	Loggie.msg("Test", "info", "multi", "argument").info()
	Loggie.msg("Test debug message.").debug()
	print()

	# Test shortcut wrappers.
	Loggie.msg("Test logging method wrappers").box(25).info()
	Loggie.error("Error wrapper test.")
	Loggie.warn("Warn wrapper test.")
	Loggie.notice("Notice wrapper test.")
	Loggie.info("Info wrapper test.")
	Loggie.debug("Debug wrapper test.")
	print()

func test_output_from_classes_of_various_inheritances_and_origins():
	Loggie.msg("Test Talkers").box(25).info()
	for proxy : LoggieEnums.NamelessClassExtensionNameProxy in LoggieEnums.NamelessClassExtensionNameProxy.values():
		Loggie.class_names = {}
		Loggie.settings.nameless_class_name_proxy = proxy

		Loggie.msg("Using proxy: {proxy}".format({
			"proxy": LoggieEnums.NamelessClassExtensionNameProxy.keys()[proxy]
		})).header().info()

		LoggieAutoloadedTalker.say("This is an autoload class.")

		# Test outputting a message from a different script.
		# If 'Loggie.settings.derive_and_show_class_names' is true, the name of the class should show up properly as prefix -
		# But the way it is represented also depends on the `Loggie.settings.nameless_class_name_proxy`, in case the
		# class_name is empty.
		var talker = LoggieTalker.new()
		talker.say("This is a named class that extends a base type (Node).")

		# Test how it looks when code from an inner-class defined in LoggieTalker produces a log.
		talker.say_from_inner("This is an inner-class defined in that class.")

		# Test how it looks when a script that has a `class_name` and extends LoggieTalker produces a log.
		SCRIPT_LOGGIE_TALKER_NAMED_CHILD.new().say("This is a named class that extends a named class and has its own implementation of a method.")

		# Test how it looks when a script that has no `class_name` and extends LoggieTalker produces a log.
		SCRIPT_LOGGIE_TALKER_CHILD.new().say("This is an unnamed class that extends a named class and has its own implementation of a method.")

		# Test how it looks when a script that has a `class_name` and extends a LoggieTalker extender produces a log.
		SCRIPT_LOGGIE_TALKER_NAMED_GRANDCHILD.new().say("This is a named class that extends a named class that extends a named class.")

		# Test how it looks when a script that has no `class_name` and extends a LoggieTalker extender produces a log.
		SCRIPT_LOGGIE_TALKER_GRANDCHILD.new().say("This is an unnamed class that extends an unnamed class that extends a named class.")

		print()
	print()
	reset_settings()

func test_domains():
	Loggie.msg("Test Domains").box(25).info()
	# Test outputting a message from an enabled custom domain.
	Loggie.set_domain_enabled("Domain1", true)
	Loggie.msg("> This message is coming from an enabled domain. (You should be seeing this)").domain("Domain1").info()

	# Test outputting a message from a disabled domain.
	Loggie.set_domain_enabled("Domain1", false)
	Loggie.msg("Another similar message should appear below this notice if something is broken.").italic().color(Color.DIM_GRAY).notice()
	Loggie.msg("> This message is coming from a disabled domain (You shouldn't be seeing this).").domain("Domain1").error()

	# Test outputting a message from a domain that is configured to use custom channels.
	Loggie.set_domain_enabled("Domain3", true, "discord")
	Loggie.msg("> This message should be visible on discord. (You should be seeing this)").domain("Domain3").info()
	Loggie.set_domain_enabled("Domain4", true, ["discord", 53, Color.RED, "terminal"]) # Purposefully provide a partially incorrect value to test error handling.
	Loggie.msg("> This message should be visible on discord and terminal. (You should be seeing this)").domain("Domain4").info()


func test_decors():
	Loggie.msg("Test Decorations").box(25).info()

	# Test outputting a box header.
	Loggie.msg("Box Header Test").color("red").box().info()

	# Test outputting a header, with a newline and a 30 character long horizontal separator.
	Loggie.msg("Colored Header").header().color("yellow").nl().hseparator(30).info()

	# Test a supported color message of all types.
	Loggie.msg("Supported color info.").color("cyan").info()
	Loggie.msg("Supported color notice.").color("cyan").notice()
	Loggie.msg("Supported color warning.").color("cyan").warn()
	Loggie.msg("Supported color error.").color("cyan").error()
	Loggie.msg("Supported color debug.").color("cyan").debug()

	# Test a godot colored message of all types.
	# Godot-colors are colors defined as consts in the 'Color' class but not
	# explicitly supported by 'print_rich'.
	Loggie.msg("Custom colored info msg.").color(Color.SLATE_BLUE).info()
	Loggie.msg("Custom colored notice.").color(Color.SLATE_BLUE).notice()
	Loggie.msg("Custom colored warning.").color(Color.SLATE_BLUE).warn()
	Loggie.msg("Custom colored error.").color(Color.SLATE_BLUE).error()
	Loggie.msg("Custom colored debug.").color(Color.SLATE_BLUE).debug()

	# Test a custom colored message.
	# (Arbitrary hex codes).
	Loggie.msg("Custom colored info msg.").color("#3afabc").info()
	Loggie.msg("Custom colored notice.").color("#3afabc").notice()
	Loggie.msg("Custom colored warning.").color("#3afabc").warn()
	Loggie.msg("Custom colored error.").color("#3afabc").error()
	Loggie.msg("Custom colored debug.").color("#3afabc").debug()

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


func test_segments():
	# Test basic segmenting.
	var msg = Loggie.msg("Segment 1 *").endseg().add(" Segment 2 *").endseg().add(" Segment 3").info()

	# Print the 2nd segment of that segmented message:
	Loggie.info("Segment 1 is:", msg.string(1))

	# Test messages where each segment has different styles.
	Loggie.msg("SegmentKey:").bold().color(Color.ORANGE).msg("SegmentValue").color(Color.DIM_GRAY).info()
	Loggie.msg("SegHeader").header().color(Color.ORANGE).space().msg("SegPlain ").msg("SegGrayItalic").italic().color(Color.DIM_GRAY).prefix("PREFIX: ").suffix(" - SUFFIX").debug()

	print("\n\n")
	Loggie.msg("Segment1: ").color("orange").msg("Segment2").info()

func test_bbcode_to_markdown():
	var msg = Loggie.msg("Hello world").italic().color(Color.RED).msg(" - part 2 is bold").bold()
	print("Text to convert:\n{msg}".format({"msg": msg.string()}))

	#var converted_text = LoggieTools.convert_BBCode_to_markdown(msg.string())

	# Print with standard print to see what the actual output looks like without Loggie interfering with any other conversion.
	#print("Converted:\n[", converted_text, "]")

func test_discord_channel():
	# Standard test with decorations.
	Loggie.msg("Hello world").italic().msg(" - from Godot!").bold().channel("discord").info()

	# Test long message.
	var msg_2k_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz"
	Loggie.msg(msg_2k_long, msg_2k_long).channel("discord").info()

func test_slack_channel():
	# Standard test.
	Loggie.msg("Hello world").italic().msg(" - from Godot!").bold().channel("slack").info()

	# Test long message.
	var msg_2k_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz"
	Loggie.msg(msg_2k_long, msg_2k_long).channel("slack").info()

func test_update_widget():
	Loggie.version_manager = LoggieVersionManager.new()
	Loggie.version_manager.connect_logger(Loggie)
	Loggie.version_manager.update_ready.connect(func():
		var popup : Window = Loggie.version_manager.create_and_show_updater_widget(Loggie.version_manager._update)
		var widget = popup.get_children().front()
		add_child(popup)
		popup.popup_centered(widget.host_window_size)
	, CONNECT_ONE_SHOT)

#endregion
# -----------------------------------------
#region Helpers
# -----------------------------------------

## Prints helpful data about some test-related scripts.
func print_talker_scripts_data() -> void:
	var scripts = [
		SCRIPT_LOGGIE_TALKER,
		SCRIPT_LOGGIE_TALKER_CHILD,
		SCRIPT_LOGGIE_TALKER_NAMED_CHILD,
		SCRIPT_LOGGIE_TALKER_GRANDCHILD,
		SCRIPT_LOGGIE_TALKER_NAMED_GRANDCHILD
	]
	for script in scripts:
		var script_specs : LoggieSystemSpecsMsg = LoggieSystemSpecsMsg.new()
		script_specs.use_logger(Loggie)
		script_specs.embed_script_data(script).info()

## Prints the values of all LoggieSettings settings obtained from Project Settings.
## Deliberately uses [method print] instead of Loggie output methods.
func print_setting_values_from_project_settings():
	Loggie.msg("Loggie Settings (as read from Project Settings):").header().info()
	for key in LoggieSettings.project_settings.keys():
		Loggie.msg("|\t{key} = {value}".format({
			"key": key,
			"value": ProjectSettings.get_setting(key)
		})).info()
	print()

## Prints the values of all LoggieSettings settings obtained directly from the current [Loggie] singleton's [member Loggie.settings].
## Deliberately uses [method print] instead of Loggie output methods.
func print_actual_current_settings():
	Loggie.msg("Loggie Settings (as read from Loggie.settings):").header().info()
	var settings_dict = Loggie.settings.to_dict()
	Loggie.msg(settings_dict).info()
	print()

func reset_settings():
	Loggie.settings = original_settings.duplicate()

#endregion
# -----------------------------------------
