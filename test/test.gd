class_name LoggieTestPlayground extends Control

## Stores a duplicate of the [LoggieSettings] which are configured in [Loggie] in the moment this node becomes ready,
## so that you can modify `Loggie.settings` on the fly during this script while having a backup of the original state.
var original_settings : LoggieSettings

func _ready() -> void:
	original_settings = Loggie.settings.duplicate()
	setup_gui()

# -----------------------------------------
#region General GUI
# -----------------------------------------

## Sets up the starting GUI of this node before anything else starts getting done.
## Should be called during [method _ready].
func setup_gui():
	var test_channel = load("res://test/testing_props/TestChannel.gd").new()
	Loggie.add_channel(test_channel)

	var console_channel : LoggieTestConsoleChannel = load("res://test/testing_props/test_console/LoggieTestConsoleChannel.gd").new()
	console_channel.console = %LoggieTestConsole
	Loggie.add_channel(console_channel)

	%TitleScreen.show()
	%TestingScreen.hide()
	%BigLabel.text = "Loggie {version}".format({"version": Loggie.get("version_manager").version if Loggie.get("version_manager") != null else "<?>"})
	%BeginTestingBtn.pressed.connect(func():
		_enter_testing_phase(1)
	)
	
	%AcceptBtn.pressed.connect(on_accept_visual_test_case_pressed)
	%RejectBtn.pressed.connect(on_reject_visual_test_case_pressed)

## Frees all children of the %Content node.
func purge_console_content() -> void:
	for content in %Content.get_children():
		content.free()

## Configures the UI such that it shows/hides all appropriate nodes for the given
## testing phase. Phases are:
## [br]1 = Run Automated Tests
## [br]2 = Configure UI so Visual Tests can start
## [br]3 = Configure UI so final Visual Tests results can be shown.
func _enter_testing_phase(phase : int) -> void:
	%BeginTestingBtn.disabled = true
	%TitleScreen.hide()
	%TestingScreen.show()
	%LoggieTestConsole.show()

	if phase == 1:
		%LeftPanel.hide()
		%ConsoleBottomBar.hide()
		%ProgressBar.hide()
		%RejectBtn.hide()
		%AcceptBtn.hide()
		%ProceedToVisualTestsBtn.show()
		_run_automated_tests()

	if phase == 2:
		purge_console_content()
		%LeftPanel.show()
		%ConsoleBottomBar.show()
		%ProgressBar.show()
		%RejectBtn.show()
		%AcceptBtn.show()
		%ProceedToVisualTestsBtn.hide()
		
	if phase == 3:
		purge_console_content()
		%LeftPanel.show()
		%AcceptBtn.hide()
		%RejectBtn.hide()
		%ProceedToVisualTestsBtn.hide()
		%ConsoleBottomBar.show()
		_print_visual_tests_results_report()
		
#endregion
# -----------------------------------------
#region Visual Tests
# -----------------------------------------

## Internal method. 
## Starts the process of showing and running visual test cases.
## Called when the %ProceedToVisualTestsBtn is pressed.
func _run_visual_tests() -> void:
	print("---------------------------------------")
	print("\t\tVisual Testing Started")
	print("---------------------------------------")
	print("Please follow the instructions in the app window and make sure to cover all tests.")
	_create_visual_tests_list()
	_enter_testing_phase(2)
	on_visual_test_case_finished()

## Internal method.
## Populates the %VisualTestsMenu with one [VisualTestMenuEntry] UI
## widget for each available test in %VisualTestCases.
## Called during [method _run_visual_tests].
func _create_visual_tests_list() -> void:
	for child in %VisualTestsMenu.get_children():
		child.queue_free()
	
	for child in %VisualTestCases.get_children():
		if child is LoggieVisualTestCase:
			var case : LoggieVisualTestCase = child
			case.finished.connect(on_visual_test_case_finished)
			case._console = %LoggieTestConsole
			var entry : VisualTestsMenuEntry = load("res://test/testing_props/test_console/visual_tests_menu_btn.tscn").instantiate()
			entry.connect_to_test_case(case)
			entry.get_button().pressed.connect(func():
				_run_visual_test_case(case)
			)
			%VisualTestsMenu.add_child(entry)

## Internal method. Creates a final report about how the testing process and outputs it 
## to the console, and to the %LoggieTestConsole. Should only be called by [method _enter_testing_phase].
func _print_visual_tests_results_report():
	print("---------------------------------------")
	print("\t\tVisual Testing Finished")
	print("---------------------------------------")
	var states = {}
	
	for case : LoggieVisualTestCase in %VisualTestCases.get_children():
		if !states.has(case.state):
			states[case.state] = []
		states[case.state].push_back(case)
	
	%LoggieTestConsole.add_text("[b][i]All visual tests have been covered.[/i][/b]")
	
	if states.has(LoggieVisualTestCase.State.Rejected) and states[LoggieVisualTestCase.State.Rejected].size() > 0:
		%LoggieTestConsole.add_text("You have rejected the results of the following tests:")
		for case : LoggieVisualTestCase in states[LoggieVisualTestCase.State.Rejected]:
			%LoggieTestConsole.add_text("\t❌ {name}".format({"name": case.name}))
		%LoggieTestConsole.add_text("\nPlease debug and fix the issues and re-run the test module.")
		print_rich("[b][i]❌ Some of the test results were rejected - please fix the issues and re-run the test module.[/i][/b]")
	else:
		%LoggieTestConsole.add_text("[color=pale_green]You have accepted the results of every test. Great![/color]")
		print_rich("[color=pale_green][b][i]✔️ All visual tests were accepted.[/i][/b][/color]")

	%LoggieTestConsole.add_content(HSeparator.new())
	%LoggieTestConsole.add_text("\n[color=gold]You may now close the window.[/color]")

## A method that updates the %ProgressBar to reflect the progress of how many %VisualTestCases
## are marked as accepted or rejected.
func update_progress_bar() -> void:
	%ProgressBar.max_value = %VisualTestCases.get_child_count()
	var progress_value = 0
	for child in %VisualTestCases.get_children():
		if child is LoggieVisualTestCase:
			var case : LoggieVisualTestCase = child
			if case.state != LoggieVisualTestCase.State.Undecided:
				progress_value += 1
	%ProgressBar.value = progress_value

## For all of the visual tests available in %VisualTestsMenu, returns the menu widget
## of the first one whose state is still [enum LoggieVisualtestCase.State.Undecided].
func _get_next_available_visual_test_case_entry() -> VisualTestsMenuEntry:
	for child in %VisualTestsMenu.get_children():
		if child is VisualTestsMenuEntry:
			var entry : VisualTestsMenuEntry = child
			if entry._case.state == LoggieVisualTestCase.State.Undecided:
				return entry
	return null

## Executed when a visual test case emits its finished signal.
func on_visual_test_case_finished() -> void:
	# Search for next available test case.
	var next_available_entry : VisualTestsMenuEntry = _get_next_available_visual_test_case_entry()
	if next_available_entry == null:
		# If none found, we are done testing, let's see results.
		_enter_testing_phase(3)
	else:
		_run_visual_test_case(next_available_entry._case)
	update_progress_bar()

## Executed when a visual test case is marked as accepted by pressing the %AcceptBtn.
func on_accept_visual_test_case_pressed() -> void:
	if !%Content.has_meta("currently_running_test_case"):
		return
	var case : LoggieVisualTestCase = %Content.get_meta("currently_running_test_case")
	case.accept()

## Executed when a visual test case is marked as rejected by pressing the %RejectBtn.
func on_reject_visual_test_case_pressed() -> void:
	if !%Content.has_meta("currently_running_test_case"):
		return
	var case : LoggieVisualTestCase = %Content.get_meta("currently_running_test_case")
	case.reject()
	
## A helper that runs the given visual test [param case].
func _run_visual_test_case(case : LoggieVisualTestCase) -> void:
	reset_settings()
	purge_console_content()
	case.run()
	%Content.set_meta("currently_running_test_case", case)

#endregion
# -----------------------------------------
#region Automated Tests
# -----------------------------------------

## Internal method. Loops through every available test (children of %AutoTestCases) and runs
## each one of them, recording the results and printing useful messages along the way.
## Should be called only by [method _enter_testing_phase].
func _run_automated_tests():
	print("---------------------------------------")
	print("\t\tAutomated Testing Started")
	print("---------------------------------------")

	# Prepare results storage.
	var results : Dictionary = {}
	for result_type in LoggieAutoTestCase.Result.values():
		results[result_type] = [] as Array[LoggieAutoTestCase]

	# Run each case and store results.
	for case : LoggieAutoTestCase in %AutoTestCases.get_children():
		Loggie.settings = case.settings
		case._console = %LoggieTestConsole
		case.c_print("[i][b][color=CORNFLOWER_BLUE]Running case:[/color] [color=DARK_TURQUOISE]{caseName}[/color][/b][/i]".format({
			"caseName" : case.get_script().get_global_name(),
		}), true, false)
		case._run_timeout_counter()
		case.call_deferred("run")
		await case.finished
		results[case.result].push_back(case)
		reset_settings()

	# Account for tests that didn't run.
	var disabled_cases : Array[LoggieAutoTestCase]
	for node in %DisabledAutoTestCases.get_children():
		if node is LoggieAutoTestCase:
			disabled_cases.push_back(node)
	results[LoggieAutoTestCase.Result.DidntRun] = disabled_cases

	# Report Results.
	var report : Dictionary = _print_automated_tests_results_report(results)
	%LoggieTestConsole.add_text(report.conclusion)
	%LoggieTestConsole.add_text(report.context)

	if report.total_failed_tests == 0:
		%LoggieTestConsole.add_text("[color=slate_gray]---------\nAutomated tests have finished.
		If interested in inspecting them, verbose details are outputted to your main/Godot console.
		When ready, please proceed to visual tests by clicking the button below.[/color]")
		%ConsoleBottomBar.show()
		%ProceedToVisualTestsBtn.pressed.connect(func():
			_run_visual_tests()
		, CONNECT_ONE_SHOT)
	else:
		%LoggieTestConsole.add_text("[color=salmon]---------\nAutomated tests have finished. Some tests failed to pass. 
		More details in your main/Godot console.
		Please fix, restart the test scene and retry.[/color]")

## Internal method. Given a set of [param results] generated during [method _run_automated_tests], creates
## a final report about how the testing process went, and also outputs it to the console.
## Should only be called by [method _run_automated_tests].
func _print_automated_tests_results_report(results : Dictionary) -> Dictionary:
	print("---------------------------------------")
	print("\t\tAutomated Testing Finished")
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

	return {
		"conclusion" : conclusion,
		"context": context,
		"total_failed_tests": total_failed_tests,
	}

#endregion
# -----------------------------------------
#region Old Tests
#   Some of these need to be converted to new [LoggieAutoTestCase] or [LoggieVisualTestCase].
#   For now they remain here to be called manually when needed.
# -----------------------------------------

## Tests sending a 2k characters long message to the DIscord channel.
## Functional but deprecated. Needs to be ported into a [LoggieAutoTestCase].
func _test_discord_channel():
	# Standard test with decorations.
	Loggie.msg("Hello world").italic().msg(" - from Godot!").bold().channel("discord").info()

	# Test long message.
	var msg_2k_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz"
	Loggie.msg(msg_2k_long, msg_2k_long).channel("discord").info()

## Tests sending a 2k characters long message to a Slack channel.
## Functional but deprecated. Needs to be ported into a [LoggieAutoTestCase].
func _test_slack_channel():
	# Standard test.
	Loggie.msg("Hello world").italic().msg(" - from Godot!").bold().channel("slack").info()

	# Test long message.
	var msg_2k_long = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibzzz"
	Loggie.msg(msg_2k_long, msg_2k_long).channel("slack").info()

## A helper method useful when the Updater window widget needs to be tested.
func _test_update_widget():
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

## Resets the [LoggieSettings] on the [Loggie] singleton to the same settings that it used to have
## when this node just initialized. Also resets the settings of the "test_console" Loggie channel
## if one is configured.
func reset_settings():
	Loggie.settings = original_settings.duplicate()
	var test_channel : LoggieTestConsoleChannel = Loggie.get_channel("test_console")
	if test_channel and test_channel.has_method("reset"):
		test_channel.reset()
		

#endregion
# -----------------------------------------
