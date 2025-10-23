class_name LoggieVisualTestCase extends Node

## Emitted when this case is considered to have finished being run and evaluated by the user.
signal finished()

## Emitted when the value of [member state] changes.
signal state_changed(new_state : State)

## An enum describing all possible states in which a visual case can be.
enum State {
	Rejected, ## The results of this test have been marked as 'rejected' by the user.
	Accepted, ## The results of this test have been marked as 'accepted' by the user.
	Undecided ## The user still hasn't finished reviewing this visual test (this is the default).
}

## A string giving a descriptive title to the test which appears in the UI.
var title = ""

@warning_ignore("unused_private_class_variable")
## Used to store a reference to the externally created [LoggieTestConsole] into which the test
## may want to add content.
var _console : LoggieTestConsole

## The current state of the case. See: [enum State].
var state : State = State.Undecided :
	set(value):
		var prevValue = self.state
		state = value
		if prevValue != value:
			state_changed.emit(value)

## Should by executed by an external factor when it is time for this test to run.
## The body of this function should define and execute all of the procedures necessary
## to consider this test as complete.
func run() -> void:
	pass

## Marks this case as 'accepted' and finished.
func accept() -> void:
	state = State.Accepted
	_finish()

## Marks this case as 'rejected' and finished.
func reject() -> void:
	state = State.Rejected
	_finish()

## Internal method. Marks this case as finished, emitting the [signal finished] signal.
func _finish() -> void:
	finished.emit()
