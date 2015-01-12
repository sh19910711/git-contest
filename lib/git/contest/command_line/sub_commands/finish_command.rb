#
# git-contest-finish
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class FinishCommand < Command

      def initialize(new_args, new_input_stream = STDIN)
        super
      end

      def define_options
        opt_parser.on "--[no-]edit", "Use default commit message." do |v|
          options[:edit] = v
        end

        opt_parser.on "-k", "--keep", "Keep contest branch after merge." do
          options[:keep] = true
        end

        opt_parser.on "--rebase", "Use rebase instead of merge." do
          options[:rebase] = true
        end

        opt_parser.on "--force-delete", "Force delete contest branch after finish." do
          options[:force_delete] = true
        end

        opt_parser.on "-s", "--squash", "Use squash during merge." do
          options[:squash] = true
        end

        opt_parser.on "--fetch", "Fetch from origin before finish." do
          options[:fetch]
        end
      end

      def set_default_options
        options[:edit] = true if options[:edit].nil?
        options[:keep] = false if options[:keep].nil?
        options[:rebase] = false if options[:rebase].nil?
        options[:force_delete] = false if options[:force_delete].nil?
        options[:squash] = false if options[:squash].nil?
        options[:fetch] = false if options[:fetch].nil?
      end

      def run
        expand_contest_branch
        Git.require_branch $BRANCH

        Git.require_clean_working_tree

        if Git.remote_branches().include?("#{$ORIGIN}/#{$BRANCH}")
          if options[:fetch]
            Git.do "fetch -q \"#{$ORIGIN}\" \"#{$BRANCH}\""
            Git.do "fetch -q \"#{$ORIGIN}\" \"#{$MASTER}\""
          end
        end

        if Git.remote_branches().include?("#{$ORIGIN}/#{$BRANCH}")
            Git.require_branches_equal $BRANCH, "#{$ORIGIN}/#{$BRANCH}"
        end

        if Git.remote_branches().include?("#{$ORIGIN}/#{$MASTER}")
            Git.require_branches_equal $MASTER, "#{$ORIGIN}/#{$MASTER}"
        end

        merge_options = ""
        if options[:edit]
          merge_options += " --no-edit"
        end

        if options[:rebase]
          ret = Git.do "contest rebase \"#{$NAME}\" \"#{$MASTER}\""
          exitcode = $?.to_i
          if ! $?
            puts "Finish was aborted due to conflicts during rebase."
            exit 1
          end
        end

        Git.do "checkout #{$MASTER}"
        if Git.do("rev-list -n2 \"#{$MASTER}..#{$BRANCH}\"").lines.to_a.length == 1
            Git.do "merge --ff \"#{$BRANCH}\" #{merge_options}"
        else
          if options[:squash]
            Git.do "merge --squash \"#{$BRANCH}\" #{merge_options}"
            unless options[:edit]
              Git.do "commit -m \"Squashed commit\""
            else
              Git.do "commit"
            end
            Git.do "merge \"#{$BRANCH}\" #{merge_options}"
          else
            Git.do "merge --no-ff \"#{$BRANCH}\" #{merge_options}"
          end
        end

        helper_finish_cleanup
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

      def expand_contest_branch
        unless has_next_token?
          use_current_branch
        else
          $NAME = next_token
          $BRANCH = "#{$PREFIX}/#{$NAME}"
            Git.require_branch $BRANCH
        end
      end

      def helper_finish_cleanup
        Git.require_branch $BRANCH
        Git.require_clean_working_tree

        if options[:fetch]
          Git.do "push \"#{$ORIGIN}\" \":refs/heads/#{$BRANCH}\""
        end

        if ! options[:keep]
          if options[:force_delete]
            Git.do "branch -D #{$BRANCH}"
          else
            Git.do "branch -d #{$BRANCH}"
          end
        end

        puts ""
        puts "Summary of actions:"
        puts "- The contest branch \"#{$BRANCH}\" was merged into \"#{$MASTER}\""
        puts "- Contest branch \"#{$BRANCH}\" has been removed"
        puts "- You are now on branch \"#{$MASTER}\""
        puts ""
      end

    end

  end

end
