require 'contest/driver/common'
require 'rexml/document'
require 'contest/driver/driver_event'

module Git
  module Contest
    module Driver
      class DriverBase < DriverEvent
        def get_opts_ext
          raise 'TODO: Implement'
        end

        def submit_ext
          raise 'TODO: Implement'
        end

        def get_desc
          ''
        end

        def get_opts
          get_opts_ext
        end

        def submit(config, source_path, options)
          submit_ext config, source_path, options
        end
      end
    end
  end
end
