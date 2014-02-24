#
# aizu_online_judge.rb
#
# Copyright (c) 2013-2014 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'contest/driver/common'
require 'rexml/document'

module Contest
  module Driver
    class AizuOnlineJudgeDriver < DriverBase
      def initialize_ext
        @client = Mechanize.new {|agent|
          agent.user_agent_alias = 'Windows IE 7'
        }
      end

      def get_opts_ext
        define_options do
          opt(
            :problem_id,
            "Problem ID (Ex: 1000, 123, 0123, etc...)",
            :type => :string,
            :required => true,
          )
        end
      end

      def get_site_name
        "AOJ"
      end

      def get_problem_id(options)
        "#{options[:problem_id]}"
      end

      def get_desc
        "Aizu Online Judge (URL: http://judge.u-aizu.ac.jp)"
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
        when "ruby"
          return "Ruby"
        when "python"
          return "Python"
        when "php"
          return "PHP"
        when "javascript"
          return "JavaScript"
        else
          abort "unknown language"
        end
      end

      def submit_ext
        # start
        trigger 'start'
        problem_id = normalize_problem_id(@options[:problem_id])

        # submit
        trigger 'before_submit', @options
        submit_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0000"
        submit_page.parser.encoding = "SHIFT_JIS"
        res_page = submit_page.form_with(:action => '/onlinejudge/servlet/Submit') do |form|
          form.userID = @config["user"]
          form.password = @config["password"]
          form.problemNO = problem_id
          form.language = @options[:language]
          form.sourceCode = File.read(@options[:source])
        end.submit
        trigger 'after_submit'

        # need to get the newest waiting submissionId
        trigger 'before_wait'
        status_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/status.jsp"
        submission_id = get_submission_id status_page.body

        # wait result
        status = get_status_wait @config["user"], submission_id
        trigger(
          'after_wait',
          {
            :submission_id => submission_id,
            :status => status,
            :result => get_commit_message(status),
          }
        )
        trigger 'finish'

        get_commit_message(status)
      end

      private
      # 180 -> 0180
      def normalize_problem_id(problem_id)
        "%04d" % problem_id.to_i
      end

      def get_status_wait(user_id, submission_id)
        # wait result
        5.times do
          sleep 3
          status_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/webservice/status_log?user_id=#{user_id}&limit=1"
          status = get_status(submission_id, status_page.body)
          return status unless is_waiting(submission_id, status_page.body)
          trigger 'retry'
        end
        trigger 'timeout'
        return 'request timed out'
      end

      def status_loop(doc)
        doc.root.elements['//status_list'].elements.each('status') do |elm|
          run_id = elm.elements['run_id'].text.to_s.strip
          status = elm.elements['status'].text.to_s.strip
          yield run_id, status
        end
      end

      def is_waiting(submission_id, body)
        doc = REXML::Document.new body
        status_loop(doc) do |run_id|
          return false if run_id == submission_id
        end
        return true
      end

      def get_status(submission_id, body)
        doc = REXML::Document.new body
        status_loop(doc) do |run_id, status|
          return status if run_id == submission_id
        end
        return ''
      end

      def get_submission_id(body)
        doc = Nokogiri::HTML body
        doc.xpath('//table[@id="tableRanking"]//tr[@class="dat"]')[0].search('td')[0].text.strip
      end
    end
  end
end
