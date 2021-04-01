# frozen_string_literal: true

require 'discordrb'
require 'yaml'

# After creating the bot, create a confg.yaml file in the root directory of this project
# this line loads the secret bot token from that file
# put the config.yaml into the gitignore file. That way the token is not exposed if you push your repo to e.g Github.

CONFIG = YAML.load_file('config.yaml')
bot = Discordrb::Bot.new token: CONFIG['token']

# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want

puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'

# This method call adds an event handler that will be called on any message that exactly contains the string "Ping!".
# The code inside it will be executed, and a "Pong!" response will be sent to the channel.
bot.message(content: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.message(start_with: 'pom', in: "#bot-channel") do |event|
  minutes = event.content.split(/ /)
  event.respond "Starting Pomodoro for #{minutes[1]} minutes"
  channel = event.user.voice_channel

  channel.users.each do |user|
    p user
    user.pm("Starting Pomodoro for #{minutes[1]} minutes") unless user.username == 'Groovy'
  end

  pomo_time = Time.new + (minutes[1].to_i * 60)
  time = Time.new
  p "Pomotime: #{pomo_time}"

  until time >= pomo_time
    time = Time.new
    p "Current_Time: #{time}"
    sleep(60)
  end

  event.respond 'Pomodoro Session finished! Take a break!'
  channel.users.each do |user|
    user.pm("Finished Pomodoro for #{minutes[1]} minutes! Nice!") unless user.username == 'Groovy'
  end
end

bot.message(content: 'help') do |event|
  event.respond 'This is a pomodoro bot made by Toby. To start a pomodoro session just type pom plus the time of your session in minutes.'
  event.respond 'Example: pom 25'
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run
