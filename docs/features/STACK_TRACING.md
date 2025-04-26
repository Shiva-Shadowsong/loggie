# Stack Tracing

This feature allows you to tell Loggie to append the stack trace to the end of any message.

> [!INFO]
> A "stack trace" is a list of function calls that shows the path of execution your program took to reach a specific point in the code -  *(the line which requested the stack trace)*.

This is what a printed stack trace looks like:

![](assets/screenshots/stack_tracer.png)

This essentially shows us when and where certain methods were executed in order to get to the point which requested this message to get printed.

> [!WARNING]
> The stack you are seeing is not the *entire stack* as received from the engine.
> See more details about this below in the Stack Pruning section to see what Loggie removes.

### Using This Feature

You can use stack tracing in two ways:
#### Attach to a specific single message

Simply call the `stack()` method on the message before outputting it, and the message will have the stack trace appended to it.

```gdscript
Loggie.msg("Tell me how we got here!").stack().info()
```

#### Always attach to every Debug message

You can enable a setting that will make it so that every message outputted at the `Debug` [log level](docs/features/LOG_LEVELS.md) will get the stack trace attached to it. Go to **Project Settings -> Loggie -> Preprocessing** and toggle this option:

![](assets/screenshots/stack_trace_toggler.png)

This specific feature is only available for the [Terminal channel](docs/channels/CHANNEL_TERMINAL.md).

### Stack Pruning

The stack you are seeing is not the *entire stack* - because Loggie cuts off parts of the stack which would basically always be there, as they present a redundant bloat.

Here is what the full stack would otherwise usually look like:

![](assets/screenshots/stack_trace_pruning.png)

Loggie allows you to specify the names of files whose stack entries will be pruned.
By default, it prunes the stack entries from `loggie.gd` and `loggie_message.gd`

You can modify this in **Project Settings -> Loggie -> General -> Skipped Filenames in Stack Trace**:

![](assets/screenshots/stack_trace_pruning_options.png)

Or if you are [using Custom Settings](docs/customization/CUSTOM_SETTINGS.md), you can set this in the `load()` method instead:

```
skipped_filenames_in_stack_trace : PackedStringArray = ["loggie", "loggie_message"]
```

---

>[!NOTE]
>### Note For Loggie Contributors
>The approach I took with pruning by filename is not the best one since there could be multiple files in the entire project with the same name, e.g. 'loggie.gd' or 'loggie_message.gd'. 
>
>It doesn't check the rest of the path or an unique ID, just the name of the script.
>
>Unless I get around to patching it later myself, this is open for improvement if you want to contribute.

---
#### Related Articles:
👀 **► [Browse All Features](docs/ALL_FEATURES.md)** ► 📚 [Prev: Showing Class Names of Callers](docs/features/CLASS_NAME_DERIVATION.md)
👀 ► **[Back to User Guides](docs/USER_GUIDE.md)**

📚 ► [Channels](docs/features/CHANNELS.md)
📚 ► [Channel: Terminal](docs/channels/CHANNEL_TERMINAL.md)
📚 ► [Composing Messages](docs/features/COMPOSE_AND_OUTPUT_MESSAGES.md)
📚 ► [Using Custom LoggieSettings](docs/customization/CUSTOM_SETTINGS.md)
📚 ► [Log Levels](docs/features/LOG_LEVELS.md)