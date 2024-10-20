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

func _ready() -> void:
	original_settings = Loggie.settings.duplicate()
	setup_gui()

	#print_setting_values_from_project_settings()
	#print_actual_current_settings()
	#print_talker_scripts_data()
	
	#test_all_log_level_outputs()
	#test_decors()
	#test_output_from_classes_of_various_inheritances_and_origins()
	#test_domains()

func setup_gui():
	$Label.text = "Loggie {version}".format({"version": Loggie.VERSION})
	print_rich("[i]Edit the test.tscn _ready function and uncomment the calls to features you want to test out.[/i]")

# -----------------------------------------
#region Tests
# -----------------------------------------

func test_all_log_level_outputs():
	# Test all types of messages.
	Loggie.msg("Test logging methods").box(25).info()
	Loggie.msg("Test info").info()
	Loggie.msg("Test", "info", "multi", "argument").info()
	Loggie.msg("Test error.").error()
	Loggie.msg("Test warning.").warn()
	Loggie.msg("Test notice.").notice()
	Loggie.msg("Test debug message.").debug()
	print()

	# Test shortcut wrappers.
	Loggie.msg("Test logging method wrappers").box(25).info()
	Loggie.debug("Debug wrapper test.")
	Loggie.info("Info wrapper test.")
	Loggie.notice("Notice wrapper test.")
	Loggie.warn("Warn wrapper test.")
	Loggie.error("Error wrapper test.")
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
		SCRIPT_LOGGIE_TALKER_CHILD.new().say("This is an unnamed class that extends a named class and has its own implementation of a method'.")
		
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

func test_decors():
	Loggie.msg("Test Decorations").box(25).info()

	# Test outputting a box header.
	Loggie.msg("Box Header Test").color("red").box().info()

	# Test outputting a header, with a newline and a 30 character long horizontal separator.
	Loggie.msg("Colored Header").header().color("yellow").nl().hseparator(30).info()

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
	print()
	

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
