# Ezdrb

Write Discord bots faster (Discordrb-only).

## Install

`$ gem install ezdrb`

## Usage
`$ ezdrb <command>`

## Commands available

* `help [command]`: Lists all commands available.
* `init`: Creates a new bot in the current directory (recommended: run this in an empty directory)
* `command <command>`: Creates a new bot command. You can find all bot commands in the *commands/* directory.

## Example

**1\. Create the bot:**

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

**2\. Add commands to the bot:**

```
$ ezdrb command ping
```

All available commands are in `config/commands.yml`:

```
$ cat config/commands.yml
commands:
- ping
```

**3\. Edit commands:**

`$ vim commands/Ping.rb`. You should get something like this:

```ruby
class Ping

  def activate(bot)
    bot.command :ping do |event|
      
    end
  end

end

Ping.new
```

Write your command script inside the `bot.command` block.

**4\. Run the bot:**

Run `bot.rb`:

`$ ruby bot.rb`


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
