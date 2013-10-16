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

require 'webmock'
WebMock.disable_net_connect!

temp_dir = `mktemp -d /tmp/XXXXXXXXXXXXX`.strip
`mkdir #{temp_dir}/home`
ENV['GIT_CONTEST_TEMP_DIR'] = temp_dir
init_env
