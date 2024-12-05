@tool

## A class that describes a channel that can be used to output Loggie Messages.
class_name LoggieMsgChannel extends RefCounted

## The ID of the channel.
var ID : String = ""

## The preprocessing steps a [method LoggieMsg] that's about to be
## sent to this channel has to go through. See: [LoggieEnums.PreprocessStep] for
## the list of flags that can be used.
var preprocess_flags : int = 0

## Defines what happens when some [LoggieMsg] wants to be sent with this channel.
## [br]If you're implementing your own channel, override this function to define
## how your channel outputs the message. 
##
## You can access the last known preprocessed version of the message 
## in [LoggieMsg.last_preprocess_result].
##
## If your channel requires extra data, the data can be embedded into a message
## with [method LoggieMsg.set_meta] and read here with [method LoggieMsg.get_meta].
func send(msg : LoggieMsg, type : LoggieEnums.MsgType):
	pass
