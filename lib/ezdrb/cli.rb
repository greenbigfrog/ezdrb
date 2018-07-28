#!/usr/bin/env ruby

require "thor"
require "yaml"
require "ezdrb"

module Ezdrb

  module Helpers

    def self.validate(var, error_msg = "")
      var = Thor::Shell::Basic.new.ask error_msg while var.empty? || var.nil?
      var
    end

  end

  class CLI < Thor

    desc "init", "Initializes a Discord bot template."
    def init
      if File.file?("config/bot.yml") then
        say("You already have a Discord bot in here.")
      else
        say("Creating new EZDRB project...\n\n")

        prefix = ask("Set prefix:")
        prefix = Helpers::validate(prefix, "Error: you must set a prefix:")

        token = ask("Set token:")
        token = Helpers::validate(token, "Error: you must set a token:")

        begin
          Dir.mkdir("config")
          Dir.mkdir("commands")

          File.open("config/bot.yml", "w") do |file|
            file.write(
              <<~HEREDOC
                prefix: '#{prefix.strip}'
                token: '#{token.strip}'
              HEREDOC
            )
          end

          File.open("config/commands.yml", "w") do |file|
            file.write(
              <<~HEREDOC
                commands:
              HEREDOC
            )
          end

          File.open("Attributes.rb", "w") do |file|
            file.write(
              <<~HEREDOC
                require "yaml"

                class Attributes

                  def self.parse
                    begin
                      config = YAML.load_file("config/bot.yml")
                    rescue => e
                      puts "ERROR: Couldn't read bot.yml"
                      exit!
                    end

                    @prefix = config["prefix"]
                    @token  = config["token"]

                    if @prefix.nil? then
                      puts "ERROR: You must set a prefix"
                      exit!
                    elsif @token.nil? then
                      puts "ERROR: You must set a token"
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

          File.open("Commands.rb", "w") do |file|
            file.write(
              <<~HEREDOC
                require "yaml"

                class Commands
                  @commands = {}

                  def self.parse(bot)
                    begin
                      commands = YAML.load_file("config/commands.yml")
                      commands = commands.values.flatten.map(&:to_sym)
                    rescue => e
                      puts "ERROR: Couldn't read commands.yml"
                      exit!
                    end

                    commands.each {|command| @commands[command] = instance_eval(File.read("commands/\#{command}.rb"))}
                    @commands.each {|command| command[1].activate(bot)}
                  end

                  class << self
                    attr_reader :commands
                  end
                end
              HEREDOC
            )
          end

          File.open("bot.rb", "w") do |file|
            file.write(
              <<~HEREDOC
                require "discordrb"

                require_relative "Attributes.rb"
                require_relative "Commands.rb"

                $LOAD_PATH << Dir.pwd

                Attributes.parse
                bot = Discordrb::Commands::CommandBot.new(token: Attributes.token, prefix: Attributes.prefix)
                Commands.parse(bot)

                bot.run
              HEREDOC
            )
          end
        rescue => e
          say("Something went wrong while creating the project.")
          say(" => #{e.message}")
        end
      end
    end

    desc "command <command_name>", "Creates a new bot command"
    def command(command_name)
      command_name = command_name.strip.downcase

      begin
        commands = YAML.load_file("config/commands.yml")
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
        File.open("config/commands.yml", "a") do |file|
          file.write(
            <<~HEREDOC
                - #{command_name}
            HEREDOC
          )
        end

        File.open("commands/#{command_name.capitalize}.rb", "w") do |file|
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
        say("Something went wrong while creating the command.")
        say(" => #{e.message}")
      end
    end

  end
end