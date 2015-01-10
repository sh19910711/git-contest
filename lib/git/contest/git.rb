#
# git.rb
#
# Copyright (c) 2013 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module Git

  def self.do(*args)
    puts "git #{args.join(' ')}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
    `git #{args.join(' ')} 2>&1`.strip
  end

  # use return value
  def self.do_no_echo(*args)
    puts "git #{args.join(' ')}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
    `git #{args.join(' ')} 2>&1`
    $?.success?
  end

  #
  def self.contest_is_initialized
    Git.contest_has_master_configured &&
      Git.contest_has_prefix_configured &&
      Git.do('config --get git.contest.branch.master') != Git.do('config --get git.contest.branch.develop')
  end

  def self.contest_has_master_configured
    master = (Git.do 'config --get git.contest.branch.master').strip
    master != '' && Git.local_branches().include?(master)
  end

  def self.contest_has_develop_configured
    develop = (Git.do 'config --get git.contest.branch.develop').strip
    develop != '' && Git.local_branches().include?(develop)
  end

  def self.contest_has_prefix_configured
    Git.do_no_echo 'config --get git.contest.branch.prefix'
  end

  def self.contest_resolve_nameprefix name, prefix
    if Git.local_branch_exists "#{prefix}/#{name}"
      return name
    end
    branches = Git.local_branches().select {|branch| branch.start_with? "#{prefix}/#{name}" }
    if branches.size == 0
      abort "No branch matches prefix '#{name}'"
    else
      if branches.size == 1
        return branches[0][prefix.length..-1]
      else
        abort "Multiple branches match prefix '#{name}'"
      end
    end
  end

  #
  def self.remote_branch_exists(branch_name)
    Git.remote_branches().include?(branch_name)
  end

  def self.local_branch_exists(branch_name)
    Git.local_branches().include?(branch_name)
  end

  def self.branch_exists(branch_name)
    Git.all_branches().include?(branch_name)
  end

  def self.remote_branches
    cmd_ret = Git.do 'branch -r --no-color'
    cmd_ret.lines.map {|line|
      line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
    }
  end

  def self.local_branches
    cmd_ret = Git.do 'branch --no-color'
    cmd_ret.lines.map {|line|
      line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
    }
  end

  def self.all_branches
    cmd_ret1 = Git.do 'branch --no-color'
    cmd_ret2 = Git.do 'branch -r --no-color'
    lines = ( cmd_ret1 + cmd_ret2 ).lines
    lines.map {|line|
      line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
    }
  end

  def self.current_branch
    ret = Git.do('branch --no-color').lines
    ret = ret.grep /^\*/
    ret[0].gsub(/^[* ] /, '').strip
  end

  def self.is_clean_working_tree
    if ! Git.do_no_echo 'diff --no-ext-diff --ignore-submodules --quiet --exit-code'
      return 1
    elsif ! Git.do_no_echo 'diff-index --cached --quiet --ignore-submodules HEAD --'
      return 2
    else
      return 0
    end
  end

  def self.repo_is_headless
    ! Git.do_no_echo 'rev-parse --quiet --verify HEAD'
  end

  #
  # 0: same
  # 1: first branch needs ff
  # 2: second branch needs ff
  # 3: branch needs merge
  # 4: there is no merge
  #
  def self.compare_branches first, second
    commit1 = Git.do "rev-parse \"#{first}\""
    commit2 = Git.do "rev-parse \"#{second}\""
    if commit1 != commit2
      if Git.do_no_echo("merge-base \"#{commit1}\" \"#{commit2}\"")
        return 4
      else
        base = Git.do "merge-base \"#{commit1}\" \"#{commit2}\""
        if commit1 == base
          return 1
        elsif commit2 == base
          return 2
        else
          return 3
        end
      end
    else
      return 0
    end
  end

  def self.require_branch(branch)
    if ! Git.all_branches().include?(branch)
      abort "Branch #{branch} does not exist."
    end
  end

  def self.require_branch_absent(branch)
    if Git.all_branches().include?(branch)
      abort "Branch #{branch} already exists. Pick another name."
    end
  end

  def self.require_clean_working_tree
    ret = Git.is_clean_working_tree
    if ret == 1
      abort "fatal: Working tree contains unstaged changes. Aborting."
    end
    if ret == 2
      abort "fatal: Index contains uncommited changes. Aborting."
    end
  end

  def self.require_local_branch branch
    if ! Git.local_branch_exists branch
      abort "fatal: Local branch '#{branch}' does not exist and is required."
    end
  end

  def self.require_remote_branch branch
    if ! Git.remote_branch_exists branch
      abort "fatal: Remote branch '#{branch}' does not exist and is required."
    end
  end

  def self.require_branches_equal local, remote
    Git.require_local_branch local
    Git.require_remote_branch remote
    ret = Git.compare_branches local, remote
    if ret > 0
      puts "Branches '#{local}' and '#{remote}' have diverged."
      if ret == 1
        abort "And branch #{local} may be fast-forwarded."
      elsif ret == 2
        puts "And local branch #{local} is ahead of #{remote}"
      else
        abort "Branches need merging first."
      end
    end
  end

end # Git
