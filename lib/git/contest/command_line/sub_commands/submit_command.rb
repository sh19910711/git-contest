#
# git-contest-submit
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class SubmitCommand < Command

      def initialize(new_args, new_input_stream = STDIN)
        super

        # load sites
        $config = get_config() || {}
        $sites  = {}
        if $config.has_key? 'sites'
          $sites = $config["sites"]
        end

        # load drivers
        Contest::Driver::Utils.load_plugins

        $drivers = {}
        load_drivers
      end

      def define_options
        opt_parser.on "-h", "--help", "help" do
          usage
          exit 0
        end
      end

      def set_default_options
      end

      def run

        # check options
        sub_commands = $sites.keys

        # detect site
        unless has_next_token?
          usage
          exit 0
        end

        site = next_token.strip

        unless $sites.has_key?(site)
          if site != ""
            puts "site not found"
          else
            usage
          end
          exit 0
        end

        # detect driver
        driver_name = $sites[site]["driver"]

        unless $drivers.has_key?(driver_name)
          puts "driver not found"
          exit
        end

        #
        # Submit Start
        #
        driver = $drivers[driver_name].new(args)

        $submit_info = {}

        # set events
        driver.on(
          'start',
          Proc.new do
            puts "@start: submit"
          end
        )

        driver.on(
          'before_login',
          Proc.new do
            puts "@submit: logging in..."
          end
        )

        driver.on(
          'after_login',
          Proc.new do
            puts "@submit: login ok"
          end
        )

        driver.on(
          'before_submit',
          Proc.new do |submit_info|
            $submit_info = submit_info
            puts "@submit: doing..."
          end
        )

        driver.on(
          'after_submit',
          Proc.new do
            puts "@submit: done"
          end
        )

        driver.on(
          'before_wait',
          Proc.new do
            print "@result: waiting..."
          end
        )

        driver.on(
          'retry',
          Proc.new do
            print "."
          end
        )

        driver.on(
          'after_wait',
          Proc.new do |submission_info|
            puts ""
            next unless submission_info.is_a?(Hash)
            puts ""
            puts "@result: Submission Result"
            puts "  %s: %s" % ["submission id", "#{submission_info[:submission_id]}"]
            puts "  %s: %s" % ["status", "#{submission_info[:status]}"]
            puts ""
            if Git.contest_is_initialized
              puts "@commit"
              Git.do "add #{get_git_add_target($config["submit_rules"]["add"] || ".")}"
              Git.do "commit --allow-empty -m '#{submission_info[:result]}'"
            end
          end
        )

        driver.on(
          'finish',
          Proc.new do
            puts "@finish"
          end
        )

        # global config
        $config["submit_rules"] ||= {}
        $config["file"] ||= {}

        # set config
        driver.config = $sites[site]
        driver.config.merge! $config

        # parse driver options
        driver.options = driver.get_opts()

        result = driver.submit()

      end

      private 

      # Load Drivers
      #
      def load_drivers
        driver_names = $sites.keys().map {|key| $sites[key]["driver"] }
        driver_names.uniq.each do |driver_name|
          class_name = driver_name.clone
          class_name.gsub!(/^[a-z]/) {|c| c.upcase }
          class_name.gsub!(/(_)([a-z])/) {|c, b| $2.upcase }
          $drivers[driver_name] = Contest::Driver.const_get "#{class_name}Driver"
        end
      end

      #
      # Command Utils
      #
      def usage
        puts get_banner
        return 0
      end

      def get_banner
        res = ""
        res += "usage: git contest submit <site>\n"
        res += "\n"
        res += "Available sites are:\n"
        $sites.keys().each do |site|
          if $drivers.has_key? $sites[site]["driver"]
            driver = $drivers[$sites[site]["driver"]].new
            res += "  %-12s\t#{driver.get_desc}\n" % [site]
          else
            # TODO: driver not found
          end
        end
        res += "\n"
        res += "Try 'git contest submit <site> --help' for details.\n"
        return res
      end

      def get_git_add_target rule
        str = rule
        str = str.gsub('${source}', $submit_info[:source])
        str
      end

    end # SubmitCommand

  end # SubCommands

end # CommandLine
