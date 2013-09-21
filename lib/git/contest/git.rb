def git_do(*args)
  return `git #{args.join(' ')}`
end

def git_contest_is_initialized
  git_contest_has_master_configured && git_contest_has_prefixes_configured
end

def git_contest_has_master_configured
  master = (git_do 'config --get git.contest.branch.master').strip
  master != "" && git_local_branches().include?(master)
end

def git_local_branches
  cmd_ret = git_do 'branch --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '')
  }
end

