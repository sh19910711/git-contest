require 'git/contest/common'

module Git
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
        def trigger(type)
          @callbacks[type] = [] unless @callbacks.has_key?(type)
          @callbacks[type].each do |proc|
            proc.call
          end
        end
      end
    end
  end
end
