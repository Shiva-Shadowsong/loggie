class_name LoggieAutoTestCase extends Node

signal finished()

var result : Result = Result.DidntRun

var settings : LoggieSettings = LoggieSettings.new()

var _timeout_counter : Timer = Timer.new()

var _console : LoggieTestConsole

var c_print_verbose_details : bool = true

enum Result {
	Fail,
	Success,
	DidntRun,
	TimedOut
}

func _to_string() -> String:
	return get_script().get_global_name()

## Override this function in your test case to define how it runs.
func run():
	pass

func success():
	result = Result.Success
	_finish()

func fail():
	result = Result.Fail
	_finish()
	
func _run_timeout_counter() -> void:
	if not get_children().has(_timeout_counter):
		_timeout_counter.name = "TimeoutCounter"
		_timeout_counter.wait_time = 5.0
		_timeout_counter.one_shot = true
		_timeout_counter.timeout.connect(func():
			result = Result.TimedOut
			finished.emit()
		)
		add_child(_timeout_counter)
	_timeout_counter.start(5.0)

func _finish():
	var msg : String = "?"
	match self.result:
		Result.Success:
			msg = "[color=PALE_GREEN]✔️ Passed[/color]"
		Result.Fail:
			msg = "[color=SALMON]❌ Failed[/color]"
		Result.DidntRun:
			msg = "[color=GOLD]☢️ Didn't run[/color]"
	
	msg = "\n[i][b][color=CORNFLOWER_BLUE]Case finished:[/color] [color=DARK_TURQUOISE]{caseName}[/color] ({msg})[/b][/i]".format({
		"caseName" : self._to_string(),
		"msg" : msg
	})

	c_print(msg, true, false)
	finished.emit()

func c_print(text : String, rich : bool = false, as_verbose: bool = false) -> void:
	if as_verbose and !c_print_verbose_details:
		return
		
	var rtlabel : RichTextLabel
	if !as_verbose:
		rtlabel = _console.add_text(text)

	if rich:
		print_rich(text)
	else:
		if rtlabel:
			rtlabel.bbcode_enabled = false
		print(text)
