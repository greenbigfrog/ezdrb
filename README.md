# [Ezdrb](#top-head)

Write Discord bots faster (Discordrb-only).

## [Install](#install)

`$ gem install ezdrb`

## [Usage](#usage)
`$ ezdrb <command>`

## [Available Commands](#available-commands)

* `help [command]`: Lists all commands available.
* `event <event>`: Creates new event handler (see all available events: https://www.rubydoc.info/github/meew0/discordrb/Discordrb/EventContainer)
* `init`: Creates a new bot in the current directory (recommended: run this in an empty directory)
* `command <command>`: Creates a new bot command. You can find all bot commands in the *commands/* directory.

## (Example)[#example]

[**1\. Create the bot:**](#example-create-bot)

```
$ mkdir my-awesome-bot && cd "$_"
$ ezdrb init
Creating new EZDRB project...

Set prefix: ++
Set token: 123456789
```

By running `ls` you should get this structure:

```
$ ls
Attributes.rb  bot.rb  commands/  Commands.rb  config/
```

[**2\. Add commands to the bot:**](#example-add-commands)

```
$ ezdrb command ping
```

All available commands are in `config/commands.yml`:

```
$ cat config/commands.yml
commands:
- ping
```

[**3\. Edit commands:**](#example-edit-commands)

`$ vim commands/Ping.rb`. You should get something like this:

```ruby
class Ping

  def activate(bot)
    bot.command :ping do |event|
      puts "pong!"
    end
  end

end

Ping.new
```

Write your command script inside the `bot.command` block.

[**4\. Add event handlers to the bot:**](#example-add-event-handlers)

```
$ ezdrb event channel_create
```

All bot handlers are stored in `config/events.yml`:

```
$ cat config/events.yml
events:
- Channel_create
```

See all available events [here](https://www.rubydoc.info/github/meew0/discordrb/Discordrb/EventContainer).

[**5\. Edit handlers**](#example-edit-handlers)

`$ vim commands/Channel_create.rb`. You should get something like this:

```ruby
class Channel_create

  def activate(bot)
    bot.channel_create do |event|
      puts "channel has been added"
    end
  end

end

Channel_create.new
```

Write what your bot should do when the event is triggered inside the `bot.channel_create` block.

[**6\. Run the bot:**](#example-run-bot)

Run `bot.rb`:

`$ ruby bot.rb`

## [To do](#to-do)

- delete a bot command
- ~~add events~~
- remove events
- run the bot from ezdrb


## [License](#license)

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
