*This article assumes you're already familiar with [Composing and Outputting Messages](../features/COMPOSE_AND_OUTPUT_MESSAGES.md).*
# Segmenting Messages

Sometimes, you may want to stylize individual parts of a complex message differently.
For example, if printing a key and value - you may want to have one style for the key, and a different one for the value, like so:

![](https://i.imgur.com/SR6rzkr.png)

For this purpose, we can segment this single message into individual parts, and apply styles independently to each segment.

Whenever you create a `LoggieMsg`, you are automatically creating its first segment.

```gdscript
## Creates a message with one segment and stylizes that segment.
Loggie.msg("SegmentKey").bold().color(Color.ORANGE)
```

Now we can use the function `endseg` to end that segment, and begin a new one. 
If we apply any stylings - they will only be applied to the newest segment.

```gdscript
Loggie.msg("SegmentKey").bold().endseg().add("SegmentValue")
```

There, we ended the first segment *(and therefore started the next one)*, and added the text  `"SegmentValue"` in the next segment. Now if we chain `italic()`:

```gdscript
Loggie.msg("SegmentKey").bold().endseg().add("SegmentValue").italic()
```

Only the `"SegmentValue"` part of the message will be italic.

There is a shortcut for `endseg() + add()`, which is just calling `msg` again. 
So, instead of the above, we can write:

```gdscript
Loggie.msg("SegmentKey").bold().msg("SegmentValue").italic()
```

This keeps it shorter and more in line with what you're used to writing (`msg`).

---
> [!TIP]
> ### 🎉 Congratulations! 🥳 
> 
> This concludes the part 3 of the guide on how to work with Loggie Messages.
> You're now a certified pro at styling with Loggie!
> 
> Related articles in this series:
> 
> * ### 📚 [Part 1 - Compose and Output Messages](../features/COMPOSE_AND_OUTPUT_MESSAGES.md)
> * ### 📚 [Part 2 - Styling Messages](../customization/STYLING_MESSAGES.md)
> * ### 📚 > Part 3 - Segmenting Messages
> 
> If you have any suggestions or feature requests to make this experience even more awesome, please share them on the Loggie Discord, or open a feature proposal issue on GitHub.
> 
> [<img src="../../assets/banners/discord.png">](https://discord.gg/XPdxpMqmcs)
>
> ### Discover More
> Message composition is just one of many useful features and customizations available in Loggie.
> Continue to learn more about how to make the most out of Loggie with these topics:
> 
> * 📚 [How and where are logs stored?](../features/LOG_FILES_AND_STORAGE.md)
> * 📚 [How do Log Levels work?](../features/LOG_LEVELS.md)
> * 📚 [Channels For Output](../features/CHANNELS.md)
> * 📚 [Toggleable Message Domains](../features/DOMAINS.md)
> * 📚 [Adjusting Default Formats for Messages](MESSAGE_FORMATS.md)
> * 📚 [Using personal Loggie settings in a team](CUSTOM_SETTINGS.md)
> * 📚 [How does preprocessing work?](../features/PREPROCESSING.md)
> * ...
> * 👀 **[Browse All Features](../ALL_FEATURES.md)**
> * 👀 [Back to User Guides](../USER_GUIDE.md)

