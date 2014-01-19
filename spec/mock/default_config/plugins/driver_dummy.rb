require 'contest/driver/common'
require 'rexml/document'

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

      def get_site_name
        "Dummy"
      end

      def get_problem_id(options)
        "#{options[:contest_id]}#{options[:problem_id]}"
      end

      def get_desc
        "This is Dummy"
      end

      def resolve_language(label)
        case label
        when "clang"
          return "C"
        when "cpp"
          return "C++"
        when "java"
          return "JAVA"
        when "cpp11"
          return "C++11"
        when "cs"
          return "C#"
        when "dlang"
          return "D"
        when "golang"
          return "Go"
        when "ruby"
          return "Ruby"
        when "python2"
          return "Python2"
        when "python3"
          return "Python"
        when "php"
          return "PHP"
        when "javascript"
          return "JavaScript"
        else
          abort "unknown languag"
        end
      end

      def submit_ext
        # start
        trigger 'start'

        # submit
        if @options[:source].is_a? Array
          source_text = @options[:source].join(", ")
        else
          source_text = @options[:source]
        end
        trigger(
          'before_submit',
          {
            :source => source_text
          },
        )
        trigger 'after_submit'

        # need to get the newest waiting submissionId
        trigger 'before_wait'

        # wait result
        status = ''

        if @options[:source].is_a? Array
          File.open @options[:source][0], 'r' do |file|
            line = file.read
            if line == 'wa-code'
              status = 'Wrong Answer'
            elsif line == 'ac-code'
              status = 'Accepted'
            elsif line == 'tle-code'
              status = 'Time Limit Exceeded'
            end
          end
        elsif @options[:source].is_a? String
          File.open @options[:source], 'r' do |file|
            line = file.read
            if line == 'wa-code'
              status = 'Wrong Answer'
            elsif line == 'ac-code'
              status = 'Accepted'
            elsif line == 'tle-code'
              status = 'Time Limit Exceeded'
            end
          end
        end

        trigger(
          'after_wait',
          {
            :submission_id => '99999',
            :status => status,
            :result => get_commit_message(status),
          }
        )
        trigger 'finish'

        status
      end

      if ENV['TEST_MODE'] === 'TRUE'
        attr_writer :client
      end
    end
  end
end
