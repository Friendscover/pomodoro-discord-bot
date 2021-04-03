### Pomodoro Discord Bot

This is the pomodoro Bot I built for our own private Discord Server. It messages all connected users in the voice chat, if someone starts an pomodoro sessions and also sends messages and plays a doorbell ring sound, if the current session has been finished. 

---
After clonning the repo just run

`bundle install`

to install all dependencies. After that, add an ENV variable for your Discord bot token on your system. On the other hand you can also add a `config.yaml` file in this directory to load the bot token. For voice chat usage, the bot requires additional packages. For more information on the installation, check out [Discordrb on Github!](https://github.com/shardlab/discordrb#installation)

Running 

`ruby lib/bot.rb`

starts the bot. It prints the invite link for you to add it to your server. The bot starts pomodoro-sessions with the `pom X` command, where X is the duration in minutes, e.g. `pom 25`. It also starts a break for 5 minutes after finishing a session. The break timer can also be called with `break 5`.