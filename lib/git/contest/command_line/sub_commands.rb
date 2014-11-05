require_relative "sub_commands/config_command"

module CommandLine

  module SubCommands

    def self.all
      SubCommands.constants.select do |name|
        /.+Command$/ === name
      end
    end

  end # SubCommands

end # CommandLine
