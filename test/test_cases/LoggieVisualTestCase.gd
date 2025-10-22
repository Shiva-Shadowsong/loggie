class_name LoggieVisualTestCase extends Node

signal finished()
signal state_changed(new_state : State)

enum State {
	Rejected,
	Accepted,
	Undecided
}

var title = ""

var _console : LoggieTestConsole

var _original_settings : LoggieSettings

var state : State = State.Undecided :
	set(value):
		var prevValue = self.state
		state = value
		if prevValue != value:
			state_changed.emit(value)

func _init() -> void:
	_original_settings = Loggie.settings

func run() -> void:
	pass

func accept() -> void:
	state = State.Accepted
	_finish()

func reject() -> void:
	state = State.Rejected
	_finish()

func _finish() -> void:
	Loggie.settings = _original_settings
	finished.emit()
