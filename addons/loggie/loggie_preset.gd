## An extension of the [LoggieMsg] class, meant to clearly differentiate between a message
## that was created with the sole purpose of being used as a Preset.
## Future behaviors of the message may diverge from regular behaviors of LoggieMsg, hence
## being separated into a different class.
class_name LoggiePreset extends LoggieMsg

## A placeholder that will be placed into the content of this preset as soon as it's initialized.
## This placeholder then gets wrapped with various styles as you call methods (e.g. [method bold],
## [method italic], etc.) on the preset. Later, only this string part of the content
## gets replaced by the actual content of a message this preset is being applied to, keeping the
## wrapped styles around it. 
const content_placeholder = "{content}"

func _init(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> void:
	self.content = [content_placeholder]

## Applies the settings and styles from this preset onto the given [LoggieMsg], modifying that message
## (does not create a duplicate) and returning that same message after it has been modified.
##
## [br][br]If any styles are applied to this [LoggiePreset], the entire content of the given [LoggieMsg] will
## be collapsed into a single segment, then have this preset's styles wrapped around that segment.
## [b]This directly resizes the [member LoggieMsg.content] array on the modified message.[/b]
##
## [br][br]However, if [param only_to_current_segment] is true, only the [member LoggieMsg.content] of
## the message found at its [member LoggieMsg.current_segment_index] will be wrapped in this preset's styles and modified,
## hence no resizing of the [member LoggieMsg.content] array will occur.
##
## [br]Neither of the above described actions will occur if this preset's content was not modified by any styles in any way.
func apply_to(msg : LoggieMsg, only_to_current_segment : bool = false) -> LoggieMsg:
	if msg is LoggiePreset:
		push_error("Attempt to apply a [LoggiePreset] to another [LoggiePreset] - unsupported behavior.")
		return
	
	# Apply the settings from this setting on the given message.
	msg.domain_name = self.domain_name
	msg.used_channels = self.used_channels.duplicate()
	msg.preprocess = self.preprocess
	msg.custom_preprocess_flags = self.custom_preprocess_flags
	msg.appends_stack = self.appends_stack
	msg.dynamic_type = self.dynamic_type
	msg.strict_type = self.strict_type
	msg.environment_mode = self.environment_mode
	msg.dont_emit_log_attempted_signal = self.dont_emit_log_attempted_signal
	
	# If no modifications were done to this preset's content (no styles applied),
	# we don't need to go further.
	if self.content[0] == content_placeholder:
		return msg
	
	# Otherwise,
	# Based on the value of [param only_to_current_segment], either:
	# 1. (if true): Replace the content of the [param msg] on its current segment to be that same content, but wrapped in the styles of this preset.
	# 2. (if false): Smush the entire content of the [param msg] into a single segment, then wrap that segment in the styles of this preset. 
	var content_to_apply_preset_to : String
	
	if only_to_current_segment:
		content_to_apply_preset_to = msg.string(msg.current_segment_index)
		var new_segment_content = self.content[0].format({"content": content_to_apply_preset_to})
		msg.content[msg.current_segment_index] = new_segment_content
	else:
		content_to_apply_preset_to = msg.string()
		var new_message_content = self.content[0].format({"content": content_to_apply_preset_to})
		msg.content = [new_message_content]
	
	return msg

## Overrides the parent class method by the same name to disable its functionality.
## Presets cannot have additional segments added.
func endseg() -> LoggieMsg:
	push_warning("Attempt to call LoggieMsg.endseg on a LoggiePreset. This is not allowed. Presets shouldn't have more than 1 string content segment.")
	return self

## Overrides the parent class method by the same name to disable its functionality.
## Presets cannot have their content modified.
func msg(message = "", arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null) -> LoggieMsg:
	push_warning("Attempt to call LoggieMsg.msg on a LoggiePreset. This is not allowed. Presets cannot have string content.")
	return self

## Overrides the parent class method by the same name to disable its functionality.
## Presets cannot be outputted, they are only meant to be applied to other [LoggieMsg]s.
func output(level : LoggieEnums.LogLevel, msg_type : LoggieEnums.MsgType = LoggieEnums.MsgType.INFO) -> void:
	push_warning("Attempt to call LoggieMsg.output on a LoggiePreset. This is not allowed. Presets should only be applied to other [LoggieMsg] instances, not used directly.")
	return
