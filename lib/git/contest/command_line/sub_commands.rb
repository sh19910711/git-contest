require_relative "sub_commands/config_command"
require_relative "sub_commands/submit_command"
require_relative "sub_commands/init_command"
require_relative "sub_commands/start_command"
require_relative "sub_commands/finish_command"
require_relative "sub_commands/rebase_command"

module CommandLine

  module SubCommands

    def self.all
      SubCommands.constants.select do |name|
        /.+Command$/ === name
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

  end # SubCommands

end # CommandLine
