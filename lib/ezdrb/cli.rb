#!/usr/bin/env ruby

# ENV['DISCORDRB_NONACL'] = 'nope'

# module Discordrb
# end

require 'thor'
require 'yaml'
require 'ezdrb'

module Ezdrb

  module Helpers

    def self.validate(var, error_msg = '')
      var = Thor::Shell::Basic.new.ask error_msg while var.empty? || var.nil?
      var
    end

  end

  class CLI < Thor

    desc 'init', 'Initializes a Discord bot template.'
    def init
      if File.file?('config/bot.yml') then
        say('You already have a Discord bot in here.')
      else
        say("Creating new EZDRB project...\n\n")

        prefix = ask('Set prefix:')
        prefix = Helpers::validate(prefix, 'Error: you must set a prefix:')

        token = ask('Set token:')
        token = Helpers::validate(token, 'Error: you must set a token:')

        begin
          Dir.mkdir('config')
          Dir.mkdir('commands')
          Dir.mkdir('events')

          File.open('config/bot.yml', 'w') do |file|
            file.write(
              <<~HEREDOC
                prefix: '#{prefix.strip}'
                token: '#{token.strip}'
              HEREDOC
            )
          end

          File.open('config/commands.yml', 'w') do |file|
            file.write(
              <<~HEREDOC
                commands:
              HEREDOC
            )
          end

          File.open('config/events.yml', 'w') do |file|
            file.write(
              <<~HEREDOC
                events:
              HEREDOC
            )
          end

          File.open('Attributes.rb', 'w') do |file|
            file.write(
              <<~HEREDOC
                require 'yaml'

                class Attributes

                  def self.parse
                    begin
                      config = YAML.load_file('config/bot.yml')
                    rescue => e
                      puts "ERROR: Couldn't read bot.yml"
                      exit!
                    end

                    @prefix = config['prefix']
                    @token  = config['token']

                    if @prefix.nil? then
                      puts 'ERROR: You must set a prefix'
                      exit!
                    elsif @token.nil? then
                      puts 'ERROR: You must set a token'
                      exit!
                    end

                  end

                  class << self
                    attr_reader :prefix, :token
                  end
                end
              HEREDOC
            )
          end

          File.open('Commands.rb', 'w') do |file|
            file.write(
              <<~HEREDOC
                require 'yaml'

                class Commands
                  @commands = {}

                  def self.parse(bot)
                    begin
                      commands = YAML.load_file('config/commands.yml')
                      commands = commands.values.flatten.map(&:to_sym)
                    rescue => e
                      puts "ERROR: Couldn't read commands.yml"
                      exit!
                    end

                    commands.each { |command| @commands[command] = instance_eval(File.read("commands/\#{command.downcase.capitalize}.rb")) }
                    @commands.each { |command| command[1].activate(bot) }
                  end

                  class << self
                    attr_reader :commands
                  end
                end
              HEREDOC
            )
          end

          File.open('Events.rb', 'w') do |file|
            file.write(
              <<~HEREDOC
                require 'yaml'

                class Events
                  @events = {}

                  def self.parse(bot)
                    begin
                      events = YAML.load_file('config/events.yml')
                      events = events.values.flatten.map(&:to_sym)
                    rescue => e
                      puts "ERROR: Couldn't read events.yml"
                      exit!
                    end

                    events.each { |event| @events[event] = instance_eval(File.read("events/\#{event.downcase.capitalize}.rb")) }
                    @events.each { |event| event[1].activate(bot) }
                  end

                  class << self
                    attr_reader :events
                  end
                end
              HEREDOC
            )
          end

          File.open('bot.rb', 'w') do |file|
            file.write(
              <<~HEREDOC
                require 'discordrb'

                require_relative 'Attributes.rb'
                require_relative 'Commands.rb'
                require_relative 'Events.rb'

                $LOAD_PATH << Dir.pwd

                Attributes.parse
                bot = Discordrb::Commands::CommandBot.new(token: Attributes.token, prefix: Attributes.prefix)
                Commands.parse(bot)
                Events.parse(bot)

                bot.run
              HEREDOC
            )
          end
        rescue => e
          say('Something went wrong while creating the project.')
          say(" => #{e.message}")
        end
      end
    end

    desc 'command <command_name>', 'Creates a new bot command'
    def command(command_name)
      command_name = command_name.strip.downcase

      begin
        commands = YAML.load_file('config/commands.yml')
        commands = commands.values.flatten
      rescue => e
        say("ERROR: Couldn't read commands.yml")
        exit!
      end

      if commands.include?(command_name) then
        say("ERROR: #{command_name} already exists")
        exit!
      end

      begin
        File.open('config/commands.yml', 'a') do |file|
          file.write(
            <<~HEREDOC
              - #{command_name}
            HEREDOC
          )
        end

        File.open("commands/#{command_name.capitalize}.rb", 'w') do |file|
          file.write(
            <<~HEREDOC
              class #{command_name.capitalize}

                def activate(bot)
                  bot.command :#{command_name} do |event|
                    
                  end
                end

              end

              #{command_name.capitalize}.new
            HEREDOC
          )
        end
      rescue => e
        say('Something went wrong while creating the command.')
        say(" => #{e.message}")
      end
    end

    desc 'event <event>', 'Creates a new event handler'
    def event(event)
      event = event.strip.downcase
      official_events = [:ready, :disconnected, :heartbeat, :typing, :message_edit, :message_delete, :reaction_add, :reaction_remove, :reaction_remove_all, :presence, :playing, :channel_create, :channel_update, :channel_delete, :channel_recipient_add, :channel_recipient_remove, :voice_state_update, :member_join, :member_update, :member_leave, :user_ban, :user_unban, :server_create, :mention, :server_update, :server_delete, :server_emoji, :server_emoji_create, :server_emoji_delete, :private_message, :direct_message, :server_emoji_update, :raw, :unknown, :pm, :dm, :message]
      
      if official_events.include?(event.to_sym) then
        begin
          events = YAML.load_file('config/events.yml')
          events = events.values.flatten
        rescue => e
          say("ERROR: Couldn't read events.yml")
          exit!
        end

        if events.include?(event) then
          say("ERROR: #{event} already exists")
          exit!
        end

        begin
          File.open('config/events.yml', 'a') do |file|
            file.write(
              <<~HEREDOC
                - #{event.downcase.capitalize}
              HEREDOC
            )
          end

          File.open("events/#{event.downcase.capitalize}.rb", 'w') do |file|
            file.write(
              <<~HEREDOC
                class #{event.downcase.capitalize}

                  def activate(bot)
                    bot.#{event} do |event|
                      
                    end
                  end

                end

                #{event.downcase.capitalize}.new
              HEREDOC
            )
          end
        rescue => e
          say('Something went wrong while creating the command.')
          say(" => #{e.message}")
        end

      else
        say('This event does not exist.')
      end
    end

  end
end