#
# test.rb
#
# Copyright (c) 2013 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

def is_test_mode?
  ENV['TEST_MODE'] === 'TRUE'
end
