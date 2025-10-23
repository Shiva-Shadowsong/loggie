# Log Levels

Log levels are a common concept found in most loggers.

They represent categories of importance for log messages, typically ordered from most critical to least critical. 

They form a hierarchy that can help you, and the logger, better understand the significance of a message, and how to handle such a message internally.

>[!IMPORTANT]
>**The `LogLevel` is a different classification than [Message Type](../customization/MESSAGE_TYPES.md).** 
>Even though they have identical keys, and may seem interchangeable, they are not used for the same purpose.
>Read that article for more info.

### Available Levels

In Loggie, there are 5 log levels, in order of (most significant -> least significant).
They can be found in the [LoggieEnums.LogLevel](../../addons/loggie/tools/loggie_enums.gd) enum, and they are:

| Log Level | Enum Value | Outputted With Method                 | Description                                                                                                                                                                                                                                                 |
| --------- | ---------- | ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Error     | 0          | Loggie.error()<br>LoggieMsg.error()   | Used for critical errors that prevent normal operation of the application. These are issues that require immediate attention, like failed database connections, critical file system errors, or application crashes.                                        |
| Warn      | 1          | Loggie.warn()<br>LoggieMsg.warn()     | Used for potentially harmful situations that don't stop execution but should be reviewed. Examples include deprecated feature usage, resource consumption warnings, or recoverable errors that might indicate bigger problems.                              |
| Notice    | 2          | Loggie.notice()<br>LoggieMsg.notice() | Used for normal but significant events that should be highlighted. This includes important state changes, configuration modifications, or successful completion of major tasks. Useful for tracking key application events without the verbosity of `info`. |
| Info      | 3          | Loggie.info()<br>LoggieMsg.info()     | Used for general informational messages about normal application operation. This includes startup/shutdown messages, user actions, or routine operations. Helps track the normal flow of the application.                                                   |
| Debug     | 4          | Loggie.debug()<br>LoggieMsg.debug()   | Used for detailed information useful during development and troubleshooting. This includes variable values, function entry/exit points, or execution timing data. Most verbose level, that should typically be disabled in production and release builds.   |

## Using Log Levels

The descriptions in the table above can give you a hint on how each level is typically used in applications.

Loggie requires you to choose and select the levels which you want to enable in your project.

You can do that in the **Project Settings** window of Godot here:

![](../../assets/screenshots/log_levels.png)

Alternatively, if you are [using Custom Settings](../customization/CUSTOM_SETTINGS.md), you should add this to your `custom_settings.gd` load() method:

```gdscript
# Set the log level used by Loggie:
log_level = LoggieEnums.LogLevel.INFO
```

✔️ Once this is set, messages outputted on the selected log level, or **any level lower than that**, will be output.

❌ Messages coming from levels higher than the enabled one will be discarded during preprocessing and won't be output.

>[!NOTE]
>### How is this useful to me?
>For example, while you are developing your game, you may want to see all messages including 'Debug' ones - but you don't want your users to see this if they run your released application and go snooping around the log files on their device.
>
>Good news! You don't need to go and delete all your 'debug' messages throughout your codebase. Simply ensure that undesired levels are turned off by setting the appropriate value for the log level setting.

Once you're done configuring this, you can output messages to any log level using the related methods. For example:

```gdscript
# Shortcut for 'error'. Use if you don't want to apply any other customizations.
Loggie.error("Something is wrong!")

# With customizations:
Loggie.msg("Something is wrong!").bold().italic().error()
```

>[!TIP]
>If you want to output a message whose Message Type is different than the log level you want to output it on, you can use **Strict Message Typing**.
>(e.g. output an `ERROR` **type** message to `DEBUG` **log level**.)
>More info in the [Message Types](../customization/MESSAGE_TYPES.md) article.
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**  📚 ► [Next: Domains](DOMAINS.md)  

📚 ► [Channels](CHANNELS.md)  
📚 ► [Composing Messages](COMPOSE_AND_OUTPUT_MESSAGES.md)  
📚 ► [Using Custom LoggieSettings](../customization/CUSTOM_SETTINGS.md)  
📚 ► [How do Log Levels work?](LOG_LEVELS.md)  