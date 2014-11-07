#
# git-contest-init
# https://github.com/sh19910711/git-contest
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module CommandLine

  module SubCommands

    class InitCommand < Command

      def initialize(new_args, new_input_stream = STDIN)
        super
      end

      def define_options
        opt_parser.on "-d", "--defaults", "Use default branch naming conventions." do
          options[:defaults] = true
        end

        opt_parser.on "-f", "--force", "force setting of git-contest branches, even if already configured." do
          options[:force] = true
        end
      end

      def set_default_options
        options[:defaults]  = false if options[:defaults].nil?
        options[:force]     = false if options[:defaults].nil?
      end

      def run
        if Git.contest_is_initialized && ! options[:force]
          puts "Already initialized for git-contest."
          puts "To force reinitialization, use: git contest init -f"
          exit 0
        end

        # run commands
        if ! Git.do_no_echo 'rev-parse --git-dir'
          Git.do 'init'
        end

        # init main
        if Git.contest_has_master_configured
          master_branch = Git.do 'config --get git.contest.branch.master'
        elsif options[:defaults]
          master_branch = 'master'
        else
          master_branch = ask('Master branch name: ') do |q|
            q.default = 'master'
          end
        end

        if options[:defaults]
          prefix = 'contest'
        else
          prefix = ask('Prefix of contest branch name:  ') do |q|
            q.default = 'contest'
          end
        end

        if Git.repo_is_headless
          Git.do 'symbolic-ref', 'HEAD', "\"refs/heads/#{master_branch}\""
            Git.do 'commit --allow-empty --quiet -m "Initial commit"'
        end

        # save config
        Git.do 'config', 'git.contest.branch.master', master_branch
        Git.do 'config', 'git.contest.branch.prefix', prefix
      end

    end # InitCommand

  end # SubCommands

end  # CommandLine
