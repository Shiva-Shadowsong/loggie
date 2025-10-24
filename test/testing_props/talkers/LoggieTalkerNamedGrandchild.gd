# For the purposes of testing class name derivation features, 
# this script is intentionally referring to its parent class with a
# literal string path instead of a defined class_name.
class_name LoggieTalkerNamedGrandchild extends "res://test/testing_props/talkers/LoggieTalkerNamedChild.gd"

## Outputs an info message.
func say(msg : String):
	Loggie.msg(msg).info()

## Outputs an info message from an [InnerTalkerTwo].
func say_from_inner_two(msg : String):
	InnerTalkerTwo.new().say(msg)

class InnerTalkerTwo extends RefCounted:
	func say(msg : String):
		Loggie.msg(msg).info()
