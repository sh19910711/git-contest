require 'yaml'

def get_config
  config_path = File.expand_path('~/.contest_config.yml')
  YAML.load_file config_path
end

def git_do(*args)
  puts `git #{args.join(' ')}`
end
