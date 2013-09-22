def git_do(*args)
  puts "git #{args.join(' ')}"
  return `git #{args.join(' ')}`
end

def git_do_no_echo(*args)
  puts "git #{args.join(' ')}"
  system "git #{args.join(' ')} >/dev/null 2>&1"
end

def git_contest_is_initialized
  git_contest_has_master_configured && git_contest_has_prefixes_configured
end

def git_contest_has_master_configured
  master = (git_do 'config --get git.contest.branch.master').strip
  master != "" && git_local_branches().include?(master)
end

def git_local_branch_exists(branch_name)
  git_local_branches().include?(branch_name)
end

def git_local_branches
  cmd_ret = git_do 'branch --no-color'
  cmd_ret.lines.map {|line|
    line.gsub(/^[*]?\s*/, '').gsub(/\s*$/, '')
  }
end


