def git_do(*args)
  puts "git #{args.join(' ')}"
  return `git #{args.join(' ')}`.strip
end

def git_do_no_echo(*args)
  puts "git #{args.join(' ')}"
  system "git #{args.join(' ')} >/dev/null 2>&1"
end

#
def git_contest_is_initialized
  git_contest_has_master_configured &&
    git_contest_has_prefixes_configured &&
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

#
def git_remote_branch_exists(branch_name)
  git_remote_branches().include?(branch_name)
end

def git_local_branch_exists(branch_name)
  git_local_branches().include?(branch_name)
end

def git_remote_branches
  cmd_ret = git_do 'branch -r --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '')
  }
end

def git_local_branches
  cmd_ret = git_do 'branch --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '')
  }
end

def git_all_branches
  cmd_ret1 = git_do 'branch --no-color'
  cmd_ret2 = git_do 'branch -r --no-color'
  lines = cmd_ret1.lines + cmd_ret2.lines
  lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '')
  }
end

#
def git_repo_is_headless
  ! git_do_no_echo 'rev-parse --quiet --verify HEAD'
end

