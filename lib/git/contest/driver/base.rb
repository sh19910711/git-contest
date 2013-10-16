require 'git/contest/common'
require 'git/contest/driver/common'
require 'rexml/document'
require 'git/contest/driver/driver_event'

module Git
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
            version "git-contest #{Git::Contest::VERSION} (c) 2013 Hiroyuki Sano"
            blocks.each do |b|
              instance_eval &b
            end
          end
        end

        def submit(config, source_path, options)
          source_path = Utils.resolve_path(options[:source] || source_path)
          options[:language] ||= Utils.resolve_language(source_path)
          options[:language] = resolve_language options[:language]
          p options
          submit_ext config, source_path, options
        end
      end
    end
  end
end

