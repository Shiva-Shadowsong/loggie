# Message Output Environment

Messages can be configured to successfully output in 3 types of environment, found in the `LoggieEnums.MsgEnvironment` enum:

| Environment (key) | Value | Description                                                                                                     |
| ----------------- | ----- | --------------------------------------------------------------------------------------------------------------- |
| BOTH              | 0     | The message will be outputted in either of the other two environments.                                          |
| ENGINE            | 1     | The message will only be outputted if the script requesting the output is running in-engine (**@tool** scripts) |
| RUNTIME           | 2     | The message will only be outputted if the script requesting the output is running in a launched project.        |

The default is `BOTH`.
This can be configured in `LoggieMsg.environment_mode` via the `LoggieMsg.env` method modifier:

```gdscript
## Output it only from ingame:
Loggie.msg("Hello from ingame.").env(LoggieEnums.MsgEnvironment.RUNTIME).info()

## Output it only in @tool scripts:
Loggie.msg("Hello from tool script.").env(LoggieEnums.MsgEnvironment.ENGINE).info()

## Output it in either environment (default behavior, hence redundant):
Loggie.msg("Hello from anywhere.").env(LoggieEnums.MsgEnvironment.BOTH).info()
Loggie.msg("Hello from anywhere.").info() ## <- Is same as above.
```

#### Related Articles:
👀 **► [Browse All Features](../ALL_FEATURES.md)**  
