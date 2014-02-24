require 'webmock'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'git/contest/common'
require 'contest/driver'

module SpecHelpers
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
    ENV['GIT_CONTEST_HOME'] = get_path('/mock/default_config')
  end

  def debug_print
    puts `pwd`
    puts `ls -a`
    puts ""
  end

  def debug_on
    ENV['GIT_CONTEST_DEBUG'] = 'ON'
  end

  def bin_exec(args, input=nil)
    puts "Commmand: #{bin_path('git-contest')} #{args}" if ENV['GIT_CONTEST_DEBUG'] == 'ON'
    pipe_cmd = ""
    pipe_cmd = "printf \" #{input}\" | " unless input.nil?
    ret = `#{pipe_cmd}#{bin_path('git-contest')} #{args} 2>&1`
    ret
  end

  def set_git_contest_config(body)
    ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/home/config.yml"
    File.open ENV['GIT_CONTEST_CONFIG'], "w" do |file|
      file.write body
    end
  end
end

RSpec.configure do |config|
  config.include SpecHelpers
  config.before :each do
    WebMock.disable_net_connect!
    @temp_dir = `mktemp -d /tmp/XXXXXXXXXXXXX`.strip
    Dir.chdir "#{@temp_dir}"
    Dir.mkdir "home"
    init_env
  end
  config.order = 'random'
end

