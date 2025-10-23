### **The `Loggie.log_attempted` signal**

Whenever a message attempts to be outputted, regardless of whether the attempt is successful or not, `Loggie` will emit the `log_attempted` signal, informing you about which message tried to be outputted, and what the result of that attempt was.

You can connect to this signal and do something in such cases, like in this example:

```swift
// Connect to the signal:
Loggie.log_attempted.connect(on_log_attempted)

// Do something when signal is received:
func on_log_attempted(msg : LoggieMsg, msg_string : String, result : LoggieEnums.LogAttemptResult):
	if result != LoggieEnums.LogAttemptResult.SUCCESS:
		push_error("Tried outputting a message '", msg_string, "', but it didn't work! Reason:", result)
```

### Preventing the signal from emitting

Sometimes, especially during specific debugging or tooling scenarios, it might be desirable to prevent a specific `LoggieMsg` from emitting the `Loggie.log_attempted` signal, regardless of the result of the output.

This is prevented if the message has the following property set to `true`:

```swift
LoggieMsg.dont_emit_log_attempted_signal = true
```

There is a modifier that lets you quickly configure this behavior on a message - the `no_signal()` modifier:

```swift
Loggie.msg("Hello.").no_signal().info()
```

---
#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**
📚 ► [Composing Messages](COMPOSE_AND_OUTPUT_MESSAGES.md)  