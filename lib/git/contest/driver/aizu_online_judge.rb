require 'git/contest/common'
require 'mechanize'
require 'nokogiri'
require 'trollop'
require 'rexml/document'

module Git
  module Contest
    module Driver
      class AizuOnlineJudge < DriverEvent
        def get_opts
          opts = Trollop::options do
            opt(
              :problem_id,
              "Problem ID (Ex: 1000, 123, 0123, etc...)",
              :type => :string,
              :required => true,
            )
          end
          return opts
        end

        def get_desc
          "Aizu Online Judge (URL: http://judge.u-aizu.ac.jp)"
        end

        def submit(config, source_path, options)
          # start
          trigger 'start'
          problem_id = "%04d" % options[:problem_id]

          @client = Mechanize.new {|agent|
            agent.user_agent_alias = 'Windows IE 7'
          }

          # submit
          trigger 'before_submit'
          submit_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0000"
          submit_page.parser.encoding = "SHIFT_JIS"
          res_page = submit_page.form_with(:action => '/onlinejudge/servlet/Submit') do |form|
            form.userID = config["user"]
            form.password = config["password"]
            form.problemNO = problem_id
            form.language = "Ruby"
            form.sourceCode = File.read(source_path)
          end.submit
          trigger 'after_submit'

          # need to get the newest waiting submissionId
          trigger 'before_wait'
          status_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/status.jsp"
          submission_id = get_submission_id status_page.body

          # wait result
          status = get_status_wait config["user"], submission_id
          trigger(
            'after_wait',
            {
              :submission_id => submission_id,
              :status => status,
            }
          )
          trigger 'finish'

          return "AOJ %s: %s\nhttp://judge.u-aizu.ac.jp/onlinejudge/review.jsp?rid=#{submission_id}" % [problem_id, status]
        end

        def get_status_wait(user_id, submission_id)
          # wait result
          5.times do
            sleep 3
            status_page = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/webservice/status_log?user_id=#{user_id}&limit=1"
            status = get_status(submission_id, status_page.body)
            return status unless is_waiting(submission_id, status_page.body)
          end
          throw Error "Wait Result Timeout (Codeforces)"
        end

        def is_waiting(submission_id, body)
          doc = REXML::Document.new body
          doc.elements['//run_id'].text.strip != submission_id
        end

        def get_status(submission_id, body) 
          doc = REXML::Document.new body
          doc.elements['//status/status'].text.strip
        end

        def get_submission_id(body)
          doc = Nokogiri::HTML body
          doc.xpath('//table[@id="tableRanking"]//tr[@class="dat"]')[0].search('td')[0].text.strip
        end

      end
    end
  end
end
