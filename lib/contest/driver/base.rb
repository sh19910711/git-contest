require 'contest/driver/common'
require 'rexml/document'
require 'contest/driver/driver_event'

module Contest
  module Driver
    class DriverBase < DriverEvent
      def get_opts_ext
        # Example:
        # define_options do
        #   opt(
        #     :problem_id,
        #     "Problem ID (Ex: 1000, 123, 0123, etc...)",
        #     :type => :string,
        #     :required => true,
        #   )
        # end
        raise 'TODO: Implement'
      end

      def get_site_name
        raise 'TODO: Implement'
      end

      def get_problem_id(options)
        raise 'TODO: Implement'
      end

      def resolve_language(label)
        raise 'TODO: Implement'
      end

      def submit_ext(config, source_path, options)
        raise 'TODO: Implement'
      end

      def get_desc
        ''
      end

      def define_options &block
        @blocks ||= []
        @blocks.push(block)
      end

      def get_opts
        get_opts_ext
        define_options do
          opt(
            :source,
            "Specify submitted code (Ex: main.cpp)",
            :type => :string,
            :required => false,
          )
          opt(
            :language,
            "Specify programming language (Ex: C++, Java or etc...)",
            :type => :string,
            :required => false,
          )
        end
        Trollop::options ARGV, @blocks do |blocks|
          version "git-contest driver"
          blocks.each do |b|
            instance_eval &b
          end
        end
      end

      def get_commit_message rule, status, options
        message = rule
        message = message.gsub '${site}', get_site_name
        message = message.gsub '${problem-id}', get_problem_id(options)
        message = message.gsub '${status}', status
        return message
      end

      def submit(config, source_path, options)
        $config = get_config
        $config["submit_rules"] ||= {}
        $config["submit_rules"]["message"] ||= "${site} ${problem-id}: ${status}"
        source_path = Utils.resolve_path(options[:source] || $config["submit_rules"]["source"] || source_path)
        options[:language] ||= Utils.resolve_language(source_path)
        options[:language] = resolve_language Utils.normalize_language(options[:language])
        status = submit_ext(config, source_path, options)
        get_commit_message($config["submit_rules"]["message"], status, options)
      end
    end
  end
end
