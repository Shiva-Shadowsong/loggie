## This class is an apparatus for testing the behavior of certain Loggie features.
## It has no practical use beyond that.
class_name LoggieTalker extends Node

## Outputs an info message.
func say(msg : String):
	Loggie.msg(msg).info()

## Outputs an info message from an [InnerLoggieTalker].
func say_from_inner(msg : String):
	InnerLoggieTalker.new().say(msg)

## A helper class to test out the results of using Loggie from within an inner-class.
class InnerLoggieTalker:
	func say(msg : String):
		Loggie.msg(msg).info()
