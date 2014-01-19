#
# driver_event.rb
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

module Contest
  module Driver
    class DriverEvent
      def initialize
        @callbacks = {}
      end
      def on(type, proc)
        @callbacks[type] = [] unless @callbacks.has_key?(type)
        @callbacks[type].push proc
      end
      def off(type, proc)
        @callbacks[type] = [] unless @callbacks.has_key?(type)
        @callbacks[type].delete proc
      end
      def trigger(type, *params)
        @callbacks[type] = [] unless @callbacks.has_key?(type)
        @callbacks[type].each do |proc|
          proc.call *params
        end
      end
    end
  end
end
