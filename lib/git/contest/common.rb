require 'git/contest/version'
require 'git/contest/test'
require 'git/contest/git'
require 'git/contest/driver/codeforces'
require 'git/contest/driver/aizu_online_judge'
require 'git/contest/driver/uva_online_judge'
require 'git/contest/driver/dummy' if is_test_mode?
require 'yaml'

def init
  init_global
  init_home
end

def init_global
  $GIT_CONTEST_HOME   = File.expand_path(ENV['GIT_CONTEST_HOME'] || "~/.git-contest")
  $GIT_CONTEST_CONFIG = File.expand_path(ENV['GIT_CONTEST_CONFIG'] || "#{$GIT_CONTEST_HOME}/config.yml")
  if git_do_no_echo 'branch'
    $MASTER = git_do 'config --get git.contest.branch.master'
    $PREFIX = git_do 'config --get git.contest.branch.prefix'
    $GIT_CONTEST_GIT_OK = true
  else
    $GIT_CONTEST_GIT_OK = false
  end
end

def init_home
  if ! FileTest.exists? $GIT_CONTEST_HOME
    FileUtils.mkdir $GIT_CONTEST_HOME
  end
  if ! FileTest.exists? $GIT_CONTEST_CONFIG
    FileUtils.touch $GIT_CONTEST_CONFIG
  end
end

def get_config
  config_path = File.expand_path($GIT_CONTEST_CONFIG)
  YAML.load_file config_path
end

