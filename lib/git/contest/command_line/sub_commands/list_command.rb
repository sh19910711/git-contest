#
# git-contest-list
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class ListCommand < Command

      def initialize(new_args, new_input_stream = STDIN)
        super

        Contest::Driver::Utils.load_plugins

        $config = get_config() || {}
        $sites  = {}
        if $config.has_key? 'sites'
          $sites = $config["sites"]
        end
      end

      def define_options
      end

      def set_default_options
      end

      def run
        sub_commands = %w(sites drivers)

        type = next_token

        case type
        when "drivers"
          # show all drivers
          puts "#"
          puts "# Available Drivers"
          puts "#"
          puts ""
          drivers = Contest::Driver::Utils.get_all_drivers
          drivers.each {|driver_info|
            puts "  #{driver_info[:class_name]}"
            puts "    #{driver_info[:site_info][:desc]}"
            puts ""
          }
        when "sites"
          # show all sites
          $sites.keys.each do |site_name|
            puts "# #{site_name}"
            keys = ["driver", "user"]
            keys.each {|key| puts "    %-8s: %s" % [ key, $sites[site_name][key] ] }
            puts " \n"
          end
        else
          usage
        end

      end

      private

      #Show Banner
      def usage
        puts get_banner
        return 0
      end

      # Get Banner Text
      def get_banner
        res = ""
        res += "usage: git contest list <type>\n"
        res += "\n"
        res += "Available types are:\n"
        res += "  %-8s: show sites\n" % "sites"
        res += "  %-8s: show drivers\n" % "drivers"
        res += " \n"
        return res
      end

    end

  end

end
