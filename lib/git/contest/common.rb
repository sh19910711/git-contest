require 'git/contest/version'
require 'git/contest/git'
require 'git/contest/driver/codeforces'
require 'git/contest/driver/aizu_online_judge'
require 'git/contest/driver/uva_online_judge'
require 'yaml'

GIT_CONTEST_HOME_DEFAULT = File.expand_path('~/.git-contest')
GIT_CONTEST_CONFIG_DEFAULT = GIT_CONTEST_HOME_DEFAULT + '/config.yml'

def init
  init_env
end

def init_env
  ENV['GIT_CONTEST_HOME']   ||= GIT_CONTEST_HOME_DEFAULT
  ENV['GIT_CONTEST_CONFIG'] ||= GIT_CONTEST_CONFIG_DEFAULT
end

def get_config
  config_path = File.expand_path(ENV['GIT_CONTEST_CONFIG'])
  YAML.load_file config_path
end

