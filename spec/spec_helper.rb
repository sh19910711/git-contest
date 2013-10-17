def read_file path
  File.read get_path(path)
end

def get_path path
  File.expand_path(File.dirname(__FILE__) + path)
end

def bin_path path
  get_path("/../bin/#{path}")
end

def init_env
  ENV['TEST_MODE'] = 'TRUE'
  ENV['PATH'] = bin_path('') + ':' + ENV['PATH']
  ENV['GIT_CONTEST_HOME'] = "#{ENV['GIT_CONTEST_TEMP_DIR']}/home"
end

def debug_print
  puts `pwd`
  puts `ls -a`
  puts ""
end

def bin_exec args
  puts "Commmand: #{bin_path('git-contest')} #{args}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
  ret = `#{bin_path('git-contest')} #{args}`
  ret
end

require 'webmock'
WebMock.disable_net_connect!

temp_dir = `mktemp -d /tmp/XXXXXXXXXXXXX`.strip
`mkdir #{temp_dir}/home`
ENV['GIT_CONTEST_TEMP_DIR'] = temp_dir
init_env

$:.unshift File.expand_path('../../lib', __FILE__)
require 'git/contest/common'

