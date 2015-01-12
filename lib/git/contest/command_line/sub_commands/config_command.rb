# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'git/contest/common'
require 'active_support/core_ext/hash'

module CommandLine

  module SubCommands

    class ConfigCommand < Command

      def initialize(new_args, new_input_stream = STDIN)
        super
      end

      def define_options
      end

      def set_default_options
      end

      def run(input = "")
        type = next_token
        case type

        when "site"
          run_site
        when "get"
          run_get
        when "set"
          run_set
        else
          usage
        end

      end

      private

      def update_config!(config, keys, value)
        # update yaml value
        new_config = {}
        cur = new_config
        while ! keys.empty?
          key = keys.shift
          if keys.empty?
            cur[key] = value
          else
            cur[key] = {}
            cur = cur[key]
          end
        end
        config.deep_merge! new_config
        File.open($git_contest_config, 'w') {|f| f.write config.to_yaml }
      end

      def run_set
        if tokens.length == 1
          # read values
          keys = next_token.split('.')
          puts "input value"
          value = input_stream.gets.strip

          update_config!(get_config, keys, value)
        elsif tokens.length == 2
          # read values from command args
          keys = tokens.shift.to_s.strip.split('.')
          value = tokens.shift.to_s.strip

          update_config!(get_config, keys, value)
        else
          show_set_usage
        end
      end

      def run_get
        if tokens.length == 1
          # read key
          config = get_config
          cur = config
          keys = tokens.shift.to_s.strip.split('.')
          while ! keys.empty?
            key = keys.shift
            if cur.has_key? key
              cur = cur[key]
            else
              abort "ERROR: Not Found"
            end
          end
          # output
          if cur.is_a? Hash
            puts "keys = #{cur.keys.join(', ')}"
          else
            puts cur
          end
        else
          show_get_usage
        end
      end

      def run_site
        if tokens.length >= 1
          type = next_token
          case type
          when "add"
            run_site_add
          when "rm"
            run_site_remove
          else
            show_site_usage
          end
        else
          show_site_usage
        end
      end

      def run_site_remove
        # git-contest-config site rm
        if tokens.length == 1
          # TODO: to check not found
          site_name = tokens.shift.to_s.strip

          puts "Are you sure you want to remove `#{site_name}`?"
          this_is_yes = terminal.ask("when you remove the site, type `yes` > ").to_s

          if this_is_yes == "yes"
            # update config
            config = get_config
            config["sites"].delete site_name
            # save config
            File.open($git_contest_config, 'w') {|f| f.write config.to_yaml }
            puts ""
            puts "updated successfully!!"
            puts ""
          else
            puts ""
            puts "operation cancelled"
            puts ""
          end
          else
            show_site_rm_usage
          end
      end

      def run_site_add
        # git-contest-config site add
        if tokens.length == 1
          puts "# input site config (password will be hidden)"

          # read info
          site_name = next_token
          config = get_config

          # init config
          config["sites"][site_name] = {}

          # input site info
          # TODO: to check not found
          config["sites"][site_name]["driver"] = terminal.ask("%10s > " % "driver").to_s
          # TODO: to depend on above driver
          config["sites"][site_name]["user"] = terminal.ask("%10s > " % "user id").to_s
          config["sites"][site_name]["password"] = terminal.ask("%10s > " % "password") do |q|
            unless /mswin(?!ce)|mingw|cygwin|bccwin/ === RUBY_PLATFORM
              q.echo = "*"
            end
          end.to_s

          # set config
          File.open($git_contest_config, 'w') {|f| f.write config.to_yaml }

          puts ""
          puts "updated successfully!!"
          puts ""
        else
          show_site_add_usage
        end
      end

      def show_get_usage
        puts ""\
          "usage: git contest config get [key]\n"\
          "\n"\
          "Example Usage:\n"\
          "  $ git contest config get key1\n"\
          "  $ git contest config get namespace1.key1\n"\
          "  $ git contest config get sites.some_judge.user\n"\
          " \n"
      end

      def show_set_usage
        puts ""\
          "usage: git contest config set [key] <value>\n"\
          "\n"\
          "Example Usage:\n"\
          "  $ git contest config set key1 value1\n"\
          "    -> key1 = value1\n"\
          "  $ git contest config set key1\n"\
          "    -> set value from command-line\n"\
          "  $ git contest config set namespace1.key1 value1\n"\
          "  $ git contest config set sites.some_judge.user username\n"\
          " \n"
      end

      def show_site_usage
        puts ""\
          "usage: git contest config site <type>\n"\
          "\n"\
          "Available types are:\n"\
          "  %-8s: add site\n"\
          " \n" % ["add"]
      end

      def show_site_add_usage
        puts ""\
          "usage: git contest config site add <site-name>\n"\
          "\n"\
          "Example Usage:\n"\
          "  $ git contest config site add site1\n"\
          "  -> input information\n"\
          " \n"
      end

      def show_site_rm_usage
        puts ""\
          "usage: git contest config site rm <site-name>\n"\
          "\n"\
          "Example Usage:\n"\
          "  $ git contest config site rm site1\n"\
          " \n"
      end

      # Get Banner Text
      def get_banner
        ""\
          "usage: git contest config [type]\n"\
          "\n"\
          "Available types are:\n"\
          "  %-8s: set value\n"\
          "  %-8s: get value\n"\
          "  %-8s: set site info\n"\
          " \n" % ["set", "get", "site"]
      end

      # Show Banner
      def usage
        puts get_banner
        return 0
      end

    end # ConfigCommand

  end # SubCommands

end  # CommandLine
