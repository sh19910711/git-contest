require 'git/contest/common'
require 'git/contest/driver/common'
require 'rexml/document'

module Git
  module Contest
    module Driver
      class Dummy < DriverBase
        def get_opts_ext
          define_options do
            opt(
              :problem_id,
              "Problem ID (Ex: 1000, 123, 0123, etc...)",
              :type => :string,
              :required => true,
            )
            opt(
              :contest_id,
              "Contest ID (Ex: 1000, 123, 0123, etc...)",
              :type => :string,
              :required => true,
            )
          end
        end

        def get_desc
          "This is Dummy"
        end

        def resolve_language(label)
          case label
          when "c", "C"
            return "C"
          when "cpp", "c++", "C++"
            return "C++"
          when "java", "Java", "JAVA"
            return "JAVA"
          when "cpp11", "C++11", "c++11", "cxx"
            return "C++11"
          when "C#", "c#", "cs"
            return "C#"
          when "D", "d"
            return "D"
          when "Ruby", "ruby", "rb"
            return "Ruby"
          when "py", "python", "Python"
            return "Python"
          when "php", "PHP"
            return "PHP"
          when "JavaScript", "js", "javascript"
            return "JavaScript"
          else
            abort "unknown languag"
          end
        end

        def submit_ext(config, source_path, options)
          # start
          trigger 'start'

          # submit
          trigger 'before_submit'
          trigger 'after_submit'

          # need to get the newest waiting submissionId
          trigger 'before_wait'

          # wait result
          trigger(
            'after_wait',
            {
              :submission_id => '99999',
              :status => 'Accepted',
            }
          )
          trigger 'finish'

          return 'Dummy Driver 99999: Accepted'
        end

        if ENV['TEST_MODE'] === 'TRUE'
          attr_writer :client
        end
      end
    end
  end
end
