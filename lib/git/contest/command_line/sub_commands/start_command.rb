#
# git-contest-start
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class StartCommand < Command 

      def initialize(new_args, new_input_stream = STDIN)
        super
      end

      def define_options
        opt_parser.on "-f", "--fetch", "fetch from origin before performing operation." do
          options[:fetch] = true
        end
      end

      def set_default_options
        options[:fetch] = false if options[:fetch].nil?
      end

      def run
        p options

        unless has_next_token?
          puts "Missing argument <name>"
          exit 1
        end

        base_branch_name = $MASTER
        # specify based branch
        if tokens.length == 2
          base_branch_name = tokens[1]
        end
        contest_branch_name = "#{tokens[0]}"
        contest_branch = "#{$PREFIX}/#{contest_branch_name}"
          Git.require_branch_absent contest_branch

        # fetch origin/master
        if options[:fetch]
          Git.do "fetch -q \"#{$ORIGIN}\""
        end

        # require equal
        if Git.branch_exists "#{$ORIGIN}/#{$MASTER}"
          Git.require_branches_equal "#{$MASTER}", "#{$ORIGIN}/#{$MASTER}"
        end

        # create branch
        if ! Git.do "checkout -b \"#{contest_branch}\" \"#{base_branch_name}\""
          abort "Could not create contest branch #{contest_branch}"
        end

        puts ""
        puts "Summary of actions:"
        puts "- A new branch \"#{contest_branch}\" was created, based on \"#{base_branch_name}\""
        puts "- You are now on branch \"#{contest_branch}\""
        puts ""
        puts "Now, start committing on your contest. When done, use:"
        puts ""
        puts "    git contest finish #{contest_branch_name}"
        puts ""

      end

    end

  end

end
