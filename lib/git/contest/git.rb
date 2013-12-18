def git_do(*args)
  puts "git #{args.join(' ')}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
  return `git #{args.join(' ')} 2>&1`.strip
end

# use return value
def git_do_no_echo(*args)
  puts "git #{args.join(' ')}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
  system "git #{args.join(' ')} >/dev/null 2>&1"
end

#
def git_contest_is_initialized
  git_contest_has_master_configured &&
    git_contest_has_prefix_configured &&
    git_do('config --get git.contest.branch.master') != git_do('config --get git.contest.branch.develop')
end

def git_contest_has_master_configured
  master = (git_do 'config --get git.contest.branch.master').strip
  master != '' && git_local_branches().include?(master)
end

def git_contest_has_develop_configured
  develop = (git_do 'config --get git.contest.branch.develop').strip
  develop != '' && git_local_branches().include?(develop)
end

def git_contest_has_prefix_configured
  git_do_no_echo 'config --get git.contest.branch.prefix'
end

def git_contest_resolve_nameprefix name, prefix
  if git_local_branch_exists "#{prefix}/#{name}"
    return name
  end
  branches = git_local_branches().select {|branch| branch.start_with? "#{prefix}/#{name}" }
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
def git_remote_branch_exists(branch_name)
  git_remote_branches().include?(branch_name)
end

def git_local_branch_exists(branch_name)
  git_local_branches().include?(branch_name)
end

def git_branch_exists(branch_name)
  git_all_branches().include?(branch_name)
end

def git_remote_branches
  cmd_ret = git_do 'branch -r --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
  }
end

def git_local_branches
  cmd_ret = git_do 'branch --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
  }
end

def git_all_branches
  cmd_ret1 = git_do 'branch --no-color'
  cmd_ret2 = git_do 'branch -r --no-color'
  lines = ( cmd_ret1 + cmd_ret2 ).lines
  lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '').strip
  }
end

def git_current_branch
  ret = git_do('branch --no-color').lines
  ret = ret.grep /^\*/
  ret[0].gsub(/^[* ] /, '').strip
end

def git_is_clean_working_tree
  if ! git_do_no_echo 'diff --no-ext-diff --ignore-submodules --quiet --exit-code'
    return 1
  elsif ! git_do_no_echo 'diff-index --cached --quiet --ignore-submodules HEAD --'
    return 2
  else
    return 0
  end
end

def git_repo_is_headless
  ! git_do_no_echo 'rev-parse --quiet --verify HEAD'
end

#
# 0: same
# 1: first branch needs ff
# 2: second branch needs ff
# 3: branch needs merge
# 4: there is no merge
#
def git_compare_branches first, second
  commit1 = git_do "rev-parse \"#{first}\""
  commit2 = git_do "rev-parse \"#{second}\""
  if commit1 != commit2
    if git_do_no_echo("merge-base \"#{commit1}\" \"#{commit2}\"") > 0
      return 4
    else
      base = git_do "merge-base \"#{commit1}\" \"#{commit2}\""
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

def require_branch(branch)
  if ! git_all_branches().include?(branch)
    abort "Branch #{branch} does not exist."
  end
end

def require_branch_absent(branch)
  if git_all_branches().include?(branch)
    abort "Branch #{branch} already exists. Pick another name."
  end
end

def require_clean_working_tree
  ret = git_is_clean_working_tree
  if ret == 1
    abort "fatal: Working tree contains unstaged changes. Aborting."
  end
  if ret == 2
    abort "fatal: Index contains uncommited changes. Aborting."
  end
end

def require_local_branch branch
  if ! git_local_branch_exists branch
    abort "fatal: Local branch '#{branch}' does not exist and is required."
  end
end

def require_remote_branch branch
  if ! git_remote_branch_exists branch
    abort "fatal: Remote branch '#{branch}' does not exist and is required."
  end
end

def require_branches_equal local, remote
  require_local_branch local
  require_remote_branch remote
  ret = git_compare_branches local, remote
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

