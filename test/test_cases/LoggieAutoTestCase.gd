class_name LoggieAutoTestCase extends Node

## Emitted when this case is considered to have finished being run.
signal finished()

## Represents the result of the test case if the test case was run.
var result : Result = Result.DidntRun

## A local copy of [LoggieSettings] which is used and can be modified during the test case's execution.
var settings : LoggieSettings = LoggieSettings.new()

## Internal timer used to timeout the test case if running it takes too long. 
##(e.g. someone forgot to call [method fail], [method success], made an infinite loop, etc.)
var _timeout_counter : Timer = Timer.new()

## Used to store a reference to the externally created [LoggieTestConsole] into which the test
## may want to add content.
var _console : LoggieTestConsole

## Whether to print verbose details to the main console by the [method c_print] function.
var c_print_verbose_details : bool = true

## An enum describing all possible results of a test case.
enum Result {
	Fail, ## The test case failed.
	Success, ## The test case passed.
	DidntRun, ## The test case was not run.
	TimedOut ## The test case timed out. (e.g. someone forgot to call [method fail], [method success], made an infinite loop, etc.)
}

func _to_string() -> String:
	return get_script().get_global_name()

## Override this function in your test case to define how it runs.
func run():
	pass

## Marks this case as 'success' and finished.
func success():
	result = Result.Success
	_finish()

## Marks this case as 'fail' and finished.
func fail():
	result = Result.Fail
	_finish()
	
## Internal method. Starts the timeout counter for the test case.
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

## Internal method. Marks this case as finished, emitting the [signal finished] signal and printing a result to the main console.
func _finish():
	var msg : String = "?"
	match self.result:
		Result.Success:
			msg = "[color=PALE_GREEN]✔️ Passed[/color]"
		Result.Fail:
			msg = "[color=SALMON]❌ Failed[/color]"
		Result.DidntRun:
			msg = "[color=GOLD]☢️ Didn't run[/color]"
	
	msg = "[i][b][color=CORNFLOWER_BLUE]Case finished:[/color] [color=DARK_TURQUOISE]{caseName}[/color] ({msg})[/b][/i]".format({
		"caseName" : self._to_string(),
		"msg" : msg
	})

	c_print(msg, true, false)
	finished.emit()

## Helper method. Prints a message to the main console.
## [br]* [param text] The message to print.
## [br]* [param rich] Whether to print the message as rich text.
## [br]* [param as_verbose] Whether to print the message as a verbose detail.
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
