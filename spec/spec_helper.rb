require 'webmock'
WebMock.disable_net_connect!

ENV['TEST_MODE'] = 'TRUE'

def read_file path
  real_path = File.expand_path(File.dirname(__FILE__) + path)
  File.read real_path
end
