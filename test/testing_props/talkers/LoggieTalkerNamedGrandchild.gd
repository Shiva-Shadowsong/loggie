# For the purposes of testing class name derivation features, 
# this script is intentionally referring to its parent class with a
# literal string path instead of a defined class_name.
class_name LoggieTalkerNamedGrandchild extends "res://test/testing_props/talkers/LoggieTalkerChild.gd"

## Outputs an info message.
func say(msg : String):
	Loggie.msg(msg).info()
