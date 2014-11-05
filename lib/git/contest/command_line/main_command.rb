module CommandLine

  class MainCommand < Command

    attr_reader :sub_commands

    def initialize(new_args)
      super
      @sub_commands = SubCommands.all.freeze
    end

    def define_options
    end

    def set_default_options
    end

    def run
      if has_subcommand?
        command_name = args.shift
        call_subcommand command_name
      else
        MainCommand.usage
      end
    end

    private

    def call_subcommand(command_name)
      sub_command = to_command_class_sym(command_name)
      if sub_commands.include?(sub_command)
        cli = SubCommands.const_get(sub_command).new(args)
        cli.init
        cli.run
      else
        SubCommands.usage
      end
    end

    def self.usage
      puts "usage: git contest <subcommand>"
      puts ""
      puts "Available subcommands are:"
      puts "  %-12s Initialize a new git repo." % ["init"]
      puts "  %-12s Start a new feature branch." % ["start"]
      puts "  %-12s Finish a feature branch." % ["finish"]
      puts "  %-12s Submit a solution." % ["submit"]
      puts "  %-12s Show information (sites, drivers)." % ["list"]
      puts "  %-12s Get/Set a config value." % ["config"]
      puts ""
      puts "Try 'git contest <subcommand> help' for details."
    end

  end

end
