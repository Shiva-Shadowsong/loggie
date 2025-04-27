# Timestamps

Loggie can append timestamps to each logged message.
They may be displayed in either local system time, or UTC.

### Using Timestamps

You can toggle timestamps and your preferred time specification in **Project Settings -> Loggie -> Preprocessing**:

![](../../assets/screenshots/timestamp_options.png)

If you are [using Custom Settings](../customization/CUSTOM_SETTINGS.md), you can set this in the `load()` method instead:

```
output_timestamps = true
timestamps_use_utc = true
```

### Changing How Timestamps are Displayed

This is covered in the [Message Formats](../customization/MESSAGE_FORMATS.md) article.

---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)** 📚 ►  [Next: Showing Class Names of Callers](CLASS_NAME_DERIVATION.md)  
📚 ► [Message Formats](../customization/MESSAGE_FORMATS.md)  
📚 ► [Composing Messages](COMPOSE_AND_OUTPUT_MESSAGES.md)  
📚 ► [Using Custom LoggieSettings](../customization/CUSTOM_SETTINGS.md)  