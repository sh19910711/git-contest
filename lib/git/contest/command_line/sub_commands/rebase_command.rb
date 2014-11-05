#
# git-contest-rebase
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class RebaseCommand < Command

      def initialize(new_args)
        super
      end

      def define_options
        opt_parser.on "-i", "--interactive", "Do an interactive rebase." do
          options[:interactive] = true
        end
      end

      def set_default_options
        options[:interactive] = false if options[:interactive].nil?
      end

      def run
        expand_nameprefix_arg_or_current

        puts "Will try to rebase '#{$NAME}'..."

        Git.require_clean_working_tree
        Git.require_branch $BRANCH

        Git.do "checkout -q \"#{$BRANCH}\""
        rebase_options = ""
        if options[:interactive]
          rebase_options += " -i"
        end

        puts Git.do "rebase #{rebase_options} #{$MASTER}"

      end

      private

      def use_current_branch
        current_branch = Git.current_branch
        if current_branch.start_with? $PREFIX
          $BRANCH = current_branch.strip
          $NAME = $BRANCH[$PREFIX.length+1..-1]
        else
          puts "The current HEAD is no feature branch."
          puts "Please spefcify a <name> argument."
          abort ''
        end
      end

      def expand_nameprefix_arg name, prefix
        expanded_name = Git.contest_resolve_nameprefix name, prefix
        exitcode = $?.to_i
        if $? == 0
          $NAME = expanded_name
          $BRANCH = "#{$PREFIX}/#{$NAME}"
        else
          return 1
          end
      end

      def expand_nameprefix_arg_or_current
        if has_next_token?
          expand_nameprefix_arg tokens.first, $PREFIX
          Git.require_branch "#{$PREFIX}/#{$NAME}"
        else
          use_current_branch
          end
      end



    end

  end

end
