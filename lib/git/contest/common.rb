require 'git/contest/version'
require 'git/contest/git'
require 'git/contest/driver/driver_event'
require 'git/contest/driver/codeforces'
require 'yaml'

def get_config
  config_path = File.expand_path('~/.contest_config.yml')
  YAML.load_file config_path
end

