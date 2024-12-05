@tool

## A class that describes a channel that can be used to output Loggie Messages.
class_name LoggieMsgChannel extends RefCounted

var type : String = ""

## This function receives a preprocessed [param message] from Loggie,
## and should describe what to do with it once it wants to be output from
## this channel. Override this function in the implementation of each channel.
func dispatch(message : LoggieMsg):
	pass
