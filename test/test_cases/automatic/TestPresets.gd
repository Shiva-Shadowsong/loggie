## Extensively tests the Presets feature, creating various different presets and checking whether
## the messages they are applied to are correctly modified after applying those presets.
class_name TestPresets extends LoggieAutoTestCase

func run() -> void:
	settings.log_level = LoggieEnums.LogLevel.DEBUG
	settings.default_channels = ["terminal"]
	Loggie.set_domain_enabled("specialMsgDomain", true)
	Loggie.preset("pinkHeader").color("pink").bold().italic()
	
	var is_properly_styled = true

	# Subtest 1.
	# Test simply applying a preset to a single-segment message.
	var testmsg1 = Loggie.msg("Test1").preset("pinkHeader").info()
	var expected_content = "[i][b][color=pink]Test1[/color][/b][/i]"
	if testmsg1.string() != expected_content:
		c_print("❌ pinkHeader wasn't properly applied in subtest 1.", false, true)
		is_properly_styled = false
	
	# Subtest 2.
	# Test applying a preset to a multi-segment message, with 'only_to_current_segment = false'.
	var testmsg2 = Loggie.msg("Test2").msg("Seg2").preset("pinkHeader", false).info()
	expected_content = "[i][b][color=pink]Test2Seg2[/color][/b][/i]"
	if testmsg2.string() != expected_content:
		c_print("❌ pinkHeader wasn't properly applied in subtest 2.", false, true)
		is_properly_styled = false
	
	# Subtest 1.
	# Test applying a preset to a multi-segment message, with 'only_to_current_segment = true'.
	var testmsg3 = Loggie.msg("Test3").msg("Seg2").preset("pinkHeader", true).info()
	expected_content = "Test3[i][b][color=pink]Seg2[/color][/b][/i]"
	if testmsg3.string() != expected_content:
		c_print("❌ pinkHeader wasn't properly applied in subtest 3.", false, true)
		is_properly_styled = false
	
	# ---------------------------------------------------------------------------------------------------
	# Special test:
	# Test applying a styling preset that also modifies as much other stuff as possible about the message.
	var s_preset_name = "specialMsg"
	var s_color = "yellow"
	var s_domain = "specialMsgDomain"
	var s_channel = "terminal"
	var s_type = LoggieEnums.MsgType.NOTICE
	var s_appends_stack = true
	var s_env = LoggieEnums.MsgEnvironment.RUNTIME
	var s_doesnt_emit_signal = true
	
	Loggie.preset(s_preset_name).color(s_color).domain(s_domain).channel(s_channel).stack(s_appends_stack).type(s_type).env(s_env).no_signal(s_doesnt_emit_signal)
	
	var s_msg = Loggie.msg("Test4").msg("Seg2").preset(s_preset_name, true).debug()
	var is_identical = true
	
	c_print("Testing if msg with a complex preset applied has identical settings like the preset after applying it...", false, true)

	if !(s_msg.domain_name == s_domain):
		is_identical = false
		c_print("❌ domain_name not identical", false, true)
	if !(s_msg.used_channels.size() == 1 and s_msg.used_channels.has(s_channel)):
		is_identical = false
		c_print("❌ used_channels not identical", false, true)
	if !(s_msg.appends_stack == s_appends_stack):
		is_identical = false
		c_print("❌ appends_stack not identical", false, true)
	if !(s_msg.strict_type == s_type):
		is_identical = false
		c_print("❌ strict_type not identical", false, true)
	if !(s_msg.environment_mode == s_env):
		is_identical = false
		c_print("❌ environment_mode not identical", false, true)
	if !(s_msg.dont_emit_log_attempted_signal == s_doesnt_emit_signal):
		is_identical = false
		c_print("❌ dont_emit_log_attempted_signal not identical", false, true)
	
	if !is_identical or !is_properly_styled:
		c_print("❌ One or more settings that should've been set on the message by applying the test preset were not properly set on the message.")
		fail()
		return

	success()
	return
