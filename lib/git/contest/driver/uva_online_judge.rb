require 'git/contest/common'
require 'git/contest/driver/common'

module Git
  module Contest
    module Driver
      class UvaOnlineJudge < DriverEvent
        def get_opts
          opts = Trollop::options do
            opt(
              :problem_id,
              "Problem ID (Ex: 100, 200, etc...)",
              :type => :string,
              :required => true,
            )
          end
          return opts
        end

        def get_desc
          "UVa Online Judge (URL: http://uva.onlinejudge.org/)"
        end

        def submit(config, source_path, options)
          raise ''
          return ''
        end

        if ENV['TEST_MODE'] === 'TRUE'
          attr_writer :client
        else
        end
      end
    end
  end
end
