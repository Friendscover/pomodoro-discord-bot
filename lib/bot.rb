# frozen_string_literal: true

require 'discordrb'

# After creating the bot, create a ENV var on your system
# this line loads the secret bot token from that ENV variable
# You could also put a config.yaml with the bot token in this direcotry,
# but be aware to load the yaml file instead of the ENV var
# That way the token is not exposed if you push your repo to e.g Github!

def main
  bot = Discordrb::Bot.new token: ENV['token'], parse_self: true

  # Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
  # done once, afterwards, you can remove this part if you want
  puts "This bot's invite URL is #{bot.invite_url}."
  puts 'Click on it to invite it to your server.'

  # This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
  # The code inside it will be executed, and a "Pong!" response will be sent to the channel.
  bot.message(content: 'Ping!') do |event|
    event.respond 'Pong!'
  end

  # Start a pomodoro session for X minutes and ignores other bots
  # This bot only responds to messages in the #bot-channel text channel
  # to reduce spam. Remove that line to call the bot from any channel
  bot.message(start_with: 'pom', in: '#bot-channel') do |event|
    channel = event.user.voice_channel
    if channel.nil?
      event.respond 'You have to be connected to a voice channel.'
      event.respond 'Try again after you joined a channel!'
    else
      minutes = event.content.split(/ /)[1].to_i
      event.respond "Starting Pomodoro for #{minutes} minutes"

      pm_voice_channel(channel, minutes, true)

      start_session(minutes)

      pm_voice_channel(channel, minutes, false)

      # bots connects to voice channel to end the session
      # delete this line if you dont want a audio cue
      bot.voice_connect(channel)
      play_session_sound(event)

      # Starts a five minute break after each session
      # TODO: add an custom break time command
      event.respond 'break 5'
    end
  end

  bot.message(start_with: 'break', in: '#bot-channel') do |event|
    minutes = event.content.split(/ /)[1].to_i
    event.respond "Taking a break for #{minutes} minutes!"

    start_session(minutes)

    event.respond 'Time is up! Start a pomodoro session again!'
  end

  bot.message(content: 'help') do |event|
    event.respond 'This is a pomodoro bot made by Toby. To start a pomodoro session just type pom plus the time of your session in minutes.'
    event.respond 'Example: pom 25 or break 5!'
    event.respond 'Check https://github.com/Friendscover/pomodoro-discord-bot for more info!'
  end

  # This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord.
  # If you leave it out (try it!) the script will simply stop and the bot will not appear online.
  bot.run
end

# Loop for pomodoro sessions. Time is calculated in seconds
# The Loop sleeps for 1 minute and checks again if the pomodoro timne
# (end of session is reached) => still executes +1 minutes because of the until
# loop body executioin
def start_session(minutes)
  pomodoro_time = Time.new + (minutes * 60)
  current_time = Time.new
  p "Pomodoro Time #{pomodoro_time}"

  until current_time >= pomodoro_time
    p "Current_Time: #{current_time}"
    sleep(60)
    current_time = Time.new
  end
end

# joins the current voice channel of the current user and plays the sound
# in data/; to change the sound just replace the path with your sound path
def play_session_sound(event)
  voice_bot = event.voice
  voice_bot.play_file('data/doorbell-1.mp3')
  voice_bot.destroy
end

# This method pm user in the voice chat at the start of the session
# and after finishing a pomodro session.
def pm_voice_channel(channel, minutes, session_start)
  channel.users.each do |user|
    next if user.username == 'Groovy'

    if session_start
      user.pm("Starting Pomodoro for #{minutes} minutes")
    else
      user.pm("Finished Pomodoro for #{minutes} minutes! Nice!")
    end
  end
end

main
