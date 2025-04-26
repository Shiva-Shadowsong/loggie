# Adding Custom Channels

So, you'd like to create a new type of channel Loggie can output to?
This guide will help you learn what you need to know.

This article assumes you are familiar with the [Channels](docs/features/CHANNELS.md) article and feature.

Let's learn by example:

> I want to create a new channel which, when it receives a request from Loggie to send a message, will use the `print` function to output it in the Godot console.

#### 1. Create and store your channel script in an appropriate location

You need to create a script and give it a name that corresponds to the `ID` of your channel.

> Since in our example, we are making a channel that prints to the Godot console, let's call it "printer.gd".

Store that script in a *protected location*:

✔️ Inside of `addons/loggie/custom_channels/`
❌ Anywhere else inside of `addons/loggie/` *(would be overwritten by auto updater)*.
✔️ Anywhere else in your project.

### 2. Give Class Name and Extend LoggieChannel

Your script should have its own `class_name` and it should extend the `LoggieChannel` class.

```gdscript
# printer.gd

class_name PrinterLoggieMsgChannel extends LoggieMsgChannel
```

### 3. Set the ID and desired preprocess flags

Now we need to alter the value of the `ID` and `preprocess_flags` variables on your channel. We'll do that inside of `_init()` so that it receives these values instantly upon instantiation.

```gdscript
# printer.gd

class_name PrinterLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	ID = "printer" # same as file name
	preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME
```

The available preprocessing flags can be found in [loggie_enums.gd](../../addons/loggie/tools/loggie_enums.gd) under LoggieEnums.PreprocessStep.

By adding what I did in the example above, messages sent to this channel will have timestamps, domain names and class names appended to them during the [preprocessing](PREPROCESSING.md) step.

### 4. Define how it handles an incoming message

The only thing left to do is to instruct the channel how to handle a message.

Every time Loggie wants this channel to handle a message, it will call the method `send` on your channel.

You've inherited this method from `LoggieChannel` when you extended it, however, the original `send` method from that class **doesn't do anything**.

It's your responsibility to write an override for that method which will specify what your channel does during its execution.

Let's override the method `send` and make it do what we wanted:

```gdscript
# printer.gd

class_name PrinterLoggieMsgChannel extends LoggieMsgChannel

func _init() -> void:
	ID = "printer" # same as file name
	preprocess_flags = LoggieEnums.PreprocessStep.APPEND_TIMESTAMPS | LoggieEnums.PreprocessStep.APPEND_DOMAIN_NAME | LoggieEnums.PreprocessStep.APPEND_CLASS_NAME

func send(msg : LoggieMsg, type : LoggieEnums.MsgType):
	# The message was preprocessed before being passed to this function.
	# Let's grab the latest result of preprocessing with:
	var preprocessed_text = msg.last_preprocess_result
	
	# And print that preprocessed text:
	print(preprocessed_text)

	# --------- Extra Info ----------- #
	# We can also access the non-preprocessed version of the message's content if we need to:
	var raw_text = msg.string()
	print(raw_text)

	# We can also access the instance of Loggie which was used to send the message directly through the message if we need to:
	var loggie = msg.get_logger()
```

### 5. Register your channel in Loggie

Loggie needs to know your channel exists before it can use it.
Register your channel by creating an instance of it and calling `Loggie.add_channel` with it:

```gdscript
var my_channel = load("res://addons/loggie/custom_channels/printer.gd").new()
Loggie.add_channel(my_channel)
```

You only need to do this once during each execution of your project, at any point before you start using the channel.

---

> [!TIP]
> ### 🎉 Congratulations! 🥳 
> 
> You've created a custom Loggie channel!
> 
> If you think it's something that the Godot community could find useful, consider sharing your channel in a public repository or our Discord where we can make sure the information about its existence reaches Loggie users.
> 
> [<img src="assets/banners/discord.png">](https://discord.gg/XPdxpMqmcs)

---
#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**
📚 ► [What are Channels?](docs/features/CHANNELS.md)
📚 ► [Domains](docs/features/DOMAINS.md)