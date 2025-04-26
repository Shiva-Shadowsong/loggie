# Discord Channel

This channel comes installed with Loggie by default.

When it receives a message, it first prepares it to show up on Discord properly.

1. Converts its content to the **MARKDOWN** [Output Format Mode](../features/OUTPUT_FORMAT_MODES.md).
2. Chops up the content into appropriately sized chunks (2000 characters max) because Discord doesn't allow more in a single message.

Then, it posts these chunks to the discord webhook that can be configured in **Project Settings -> Loggie -> General -> Discord -> Live Webhook / Dev Webhook**.

> [!NOTE]
> You can generate a webhook on your Discord server by going to **Server Settings -> Integrations -> Webhooks**.

![](../../assets/screenshots/discord_webhook_area.png)

> [!CAUTION]
> ## **NEVER INCLUDE WEBHOOKS IN PUBLIC BUILDS.**
> 
> Doing so is a security risk! Use the `discord/slack` feature at your own discretion. It is best used for in-house tools, server-type applications and private projects.
>   
> For a safer public facing implementation - consider using a custom URL endpoint to send the request to one of **your own** servers which has a restrictive middleware handler that can deal with the request safely.
> 
> You can also implement your own version of these channels and deal with the issue in whichever way suitable. 

Furthermore, you can customize the features of this channel in **Project Settings -> Loggie -> Preprocessing -> Discord**:

![](../../assets/screenshots/channel_discord_customize.png)

In the end, you should receive your message on your Discord server, like in this example:

![](https://i.imgur.com/PmAygkw.png)

---
#### Related Articles:
👀 **► [Browse All Features](../../docs/ALL_FEATURES.md)**
📚 ► [What are Channels?](../../docs/features/CHANNELS.md)
📚 ► [Adding Custom Channels](../../docs/customization/ADDING_CUSTOM_CHANNELS.md)
📚 ► [Domains](../../docs/features/DOMAINS.md)