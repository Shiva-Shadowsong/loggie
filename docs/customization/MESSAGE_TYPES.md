# Message Types 

The message type is a classification of a `LoggieMsg`.

>[!IMPORTANT]
>**The `MsgType` is a different classification than [Log Level](../features/LOG_LEVELS.md).** 
>Even though they have identical keys, and may seem interchangeable, they are not used for the same purpose.
>
>The `MsgType` informs:
>
>1. The [preprocessing](../features/PREPROCESSING.md) step how to format the message.
>2. The [channel](../features/CHANNELS.md) which receives the message about what type of message that is *(for whatever reason they may want to know that, e.g. filtering)*. 
>   
> The `LogLevel` of a message, on the other hand:
> * Dictates only the level at which the message is output - eventually preventing the message from outputting if its level is not within the range of enabled log levels.
> 
> Since this differentiation exists, for example, we are able to output an `Error` **type** message, on the `Debug` **level** - allowing us to have error messages that only show up for developers during debugging

There are 5 types of messages, available in the `LoggieEnums.MsgType` enum:

| Enum Key | Enum Value | Description                                                                                                            |
| -------- | ---------- | ---------------------------------------------------------------------------------------------------------------------- |
| ERROR    | 0          | A message that is considered to be an error message, and will be formatted as an error message.                        |
| WARN     | 1          | A message that is considered to be a warning message, and will be formatted as a warning message.                      |
| NOTICE   | 2          | A message that is considered to be a notice, and will be formatted as a notice.                                        |
| INFO     | 3          | A message that is considered a standard text that is not special in any way, and will be formatted as an info message. |
| DEBUG    | 4          | A message that is considered to be a message used only during debugging, and will be formatted as a debug message.     |
## Functionality Differences

Some message types are handled differently than others during output to the default [terminal channel](../channels/CHANNEL_TERMINAL.md).

| Level | Note                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| ----- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ERROR | **Has Toggle**<br>If the setting `Output Errors To Console` is set to `true`, error type messages on the [terminal channel](../channels/CHANNEL_TERMINAL.md) will additionally get output with the `push_error` function, which will also generate an actual error in the Godot debugger tab *(recommended)*.<br><br>![../../assets/screenshots/show_error_toggle.png](../../assets/screenshots/show_error_toggle.png)<br>               |
| WARN  | **Has Toggle**<br>If the setting `Output Warnings To Console` is set to `true`, warning type messages on the [terminal channel](../channels/CHANNEL_TERMINAL.md) will additionally get output with the `push_warning` function, which will also generate an actual error in the Godot debugger tab *(recommended)*.<br><br>![../../assets/screenshots/show_warning_toggle.png](../../assets/screenshots/show_warning_toggle.png)<br><br> |
| DEBUG | **Has Stack Tracing Feature**<br>If the setting `Debug Msgs Print Stack Trace` is set to `true`, debug type messages on the `terminal` channel will additionally have a stack trace appended to them.<br><br>![../../assets/screenshots/show_stack_tracer.png](../../assets/screenshots/show_stack_tracer.png)<br>                                                                                                                       |
## Formatting Styles

By default, messages of the 5 existing types will look like this:

![](../../assets/screenshots/log_level_stylings.png)

If you wish to change their style, it can be done by altering their format setting:
**Project Settings -> Loggie -> Formats**

The available variables for these fields are:

| variable | meaning                                               |
| -------- | ----------------------------------------------------- |
| {msg}    | This will get replaced by the content of the message. |

![](../../assets/screenshots/log_level_formats.png)

If you are [using Custom Settings](../customization/CUSTOM_SETTINGS.md), you can do it with:

```gdscript
format_error_msg = "[b][color=red][ERROR]:[/color][/b] {msg}"
format_warning_msg = "[b][color=orange][WARN]:[/color][/b] {msg}"
format_notice_msg = "[b][color=cyan][NOTICE]:[/color][/b] {msg}"
format_info_msg = "{msg}"
format_debug_msg = "[b][color=pink][DEBUG]:[/color][/b] {msg}"
```

>[!WARNING]
>##### Why did you use such stark ugly colors as defaults?
>
>Loggie was originally developed on Godot 4.3.
>
>Since messages outputted by Loggie are using `print_rich` - I opted to use colors which are officially supported by `print_rich` during internal handling of BBCode stripping, and the choices there are limited in Godot 4.3.
>
>In future versions of Godot, they may fix this to support a broader set / all colors - but for backwards compatibility, I'm keeping the defaults as is.

---
## Dynamic vs Strict Message Typing

### Dynamic Message Typing

This is the default behavior of a message.

The shortcut functions like `LoggieMsg.info`, `LoggieMsg.error`, etc. are usually the ones dictating the message's type to the `output`, setting it to the same type as the log level they're meant to be outputted on. 

So, `LoggieMsg.error` will send the message at the `ERROR` debug level, and as an `ERROR` msg type.

You may, sometimes, want to differentiate between these two, and until Loggie 3.0, the only way to do that was to call:

```swift
// Output an Info message on the Debug level.
msg.output(LoggieEnums.LogLevel.DEBUG, LoggieEnums.MsgType.INFO) 
```

Which is way too verbose and uncomfortable to write numerous times.
Now we can make use of `Strict Message Typing` to do that more conveniently. See below.

### Strict Message Typing

If you want to configure a message to always be considered to be of a certain type, regardless of what debug level it is being outputted at, you can do that with the `LoggieMsg.type` method.

```swift
Loggie.msg("Error only for devs").type("error").debug()
```

Calling `type("error")` on this message permanently sets it to arrive on channels with `msg_type = LoggieEnums.MsgType.ERROR`, and be preprocessed/formatted as an error.

But now, the log level we may choose to send this message to is unaffected. 
Therefore, we can call `debug()` on this error message, and it will be sent at the `DEBUG` level, while maintaining its formatting and type as an `ERROR`.

The method `type` takes either a `LoggieEnums.MsgType` parameter, or a string that converts to one of those types, e.g. `"INFO"` or `info` (it's case-insensitive).

Once you've done this, you've disabled the `Dynamic Message Typing`.
To re-enable dynamic typing, if you should need to for some reason, you can set:

```swift
msg.dynamic_type = true
```
---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**

📚 ► [Channels](CHANNELS.md)  
📚 ► [Composing Messages](COMPOSE_AND_OUTPUT_MESSAGES.md)  
📚 ► [How do Log Levels work?](LOG_LEVELS.md)  

