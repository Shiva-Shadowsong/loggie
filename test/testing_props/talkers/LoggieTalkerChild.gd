# This script exists solely for the purposes of testing class name derivation features.
extends LoggieTalker

## Outputs an info message.
func say(msg : String):
	Loggie.msg(msg).info()
	
