# Preprocessing

The preprocessing step is an important step during your message's lifetime that is executed any time you attempt to output that message.

> All messages are preprocessed when going to the output, unless preprocessing is explicitly disabled on each message. More info in the "Disabling Preprocessing For a Message" section below.

During this step, the messages are altered in various ways to inject other Loggie features into them.

This article should provide the needed insights into what the preprocessing step does.

## What happens during preprocessing?

If we start with a `debug` type message like:

```
Hello World.
```

Multiple things will happen to it. Let's see how the result evolves over each step:
##### 1. Apply Log Level Formatting
> The format and content of the message is modified by having the matching log format applied to it. There is a different format for each of the [log levels](docs/features/LOG_LEVELS.md).
> [You can adjust how these formats look.](docs/customization/MESSAGE_FORMATS.md)

Since our example message was a `debug` type message, the message now transforms into:

```gdscript
[DEBUG]: Hello World.
```

##### 2. Append Domain
> The name of the domain is added to it, telling us which [domain](docs/features/DOMAIN.md) the message came from.
> [This feature](docs/features/DOMAINS.md#showing-domain-names-next-to-messages) has to be explicitly enabled in settings.

If we had this feature enabled, the message transforms into:

```gdscript
(DomainName) [DEBUG]: Hello World.
```

##### 3. Append Class Name
> The name of the class from which this message was sent is added to it.
> [This feature](docs/features/CLASS_NAME_DERIVATION.md#using-this-feature) has to be explicitly enabled in settings.

If we had this feature enabled, the message transforms into:

```gdscript
(Node) (DomainName) [DEBUG]: Hello World.
```

##### 4. Append Timestamp
> The format and content of the message is modified by having a timestamp added to it.
> [This feature](docs/features/TIMESTAMPS.md) has to be explicitly enabled in settings.

If we had this feature enabled, the message transforms into:

```gdscript
[25.04.2025 19:41:26] (Node) (DomainName) [DEBUG]: Hello World.
```

##### 5. Append Stack Trace
> The format and content of the message is modified by having the stack trace added to it.
> [This feature](docs/features/STACK_TRACING.md) has to be explicitly enabled in settings.

If we had this feature enabled, the message transforms into:

```gdscript
[25.04.2025 19:41:26] (Node) (DomainName) [DEBUG]: Hello World.
  0: func _ready:39 (in res://test/test.gd)
```

## Disabling Preprocessing For a Message

It is safe to disable preprocessing for certain messages, when you are sure that you don't want  that message to have any modifications done to it under the hood.

> For example, the `LoggieMsg.box()` method disables preprocessing, because any modifications done to the message after the box is drawn would ruin the shape of the box.

You can set whether the message should be preprocessed by calling `preprocessed(bool)` on it:

```gdscript
Loggie.msg("Hello.").preprocessed(false).info()
```

For the following piece of code - this is the resulting output:

```gdscript
	Loggie.msg("I am preprocessed.").notice()
	Loggie.msg("I am not.").preprocessed(false).notice()
```

![](assets/screenshots/preprocess_difference.png)

---
#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)**
📚 ► [Composing Messages](docs/features/COMPOSE_AND_OUTPUT_MESSAGES.md)
📚 ► [Using Custom LoggieSettings](docs/customization/CUSTOM_SETTINGS.md)