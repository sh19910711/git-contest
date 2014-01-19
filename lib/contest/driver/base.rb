#
# base.rb
#
# Copyright (c) 2013 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'contest/driver/common'
require 'rexml/document'
require 'contest/driver/driver_event'

module Contest
  module Driver
    DEFAULT_SOURCE_PATH = "main.*"
    DEFAULT_COMMIT_MESSAGE ="${site} ${problem-id}: ${status}"

    class DriverBase < DriverEvent
      attr_accessor :config, :options

      def initialize
        # submit options
        @options ||= {}
        # site config
        @config ||= {}
        @config["submit_rules"] ||= {}
        # call DriverEvent#initialize
        super
      end

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
        get_opts_ext()
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
          opt(
            :message,
            "Set git-commit message",
            :type => :string,
            :required => false,
          )
        end
        Trollop::options ARGV, @blocks do |blocks|
          version "git-contest driver"
          # set driver options
          blocks.each do |b|
            instance_eval &b
          end
        end
      end

      def get_commit_message_ext
        nil
      end

      def get_commit_message status
        if @options[:message].nil?
          message = @config["submit_rules"]["message"] || DEFAULT_COMMIT_MESSAGE
          message = message.gsub '${site}', get_site_name
          message = message.gsub '${problem-id}', get_problem_id(options)
          message = message.gsub '${status}', status
          message = "\n#{get_commit_message_ext}" unless get_commit_message_ext.nil?
        else
          message = @options[:message]
        end
        message
      end

      # submit a solution
      def submit
        @options[:source] = Utils.resolve_path(
          @options[:source] || @config["submit_rules"]["source"] || DEFAULT_SOURCE_PATH
        )
        @options[:language] ||= Utils.resolve_language(@options[:source])
        @options[:language] = resolve_language Utils.normalize_language(@options[:language])

        submit_ext()
      end
    end
  end
end
