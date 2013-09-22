require 'git/contest/common'
require 'mechanize'
require 'nokogiri'
require 'trollop'

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
          problem_id = options[:problem_id]

          @client = Mechanize.new {|agent|
            agent.user_agent_alias = 'Windows IE 7'
          }

          # submit
          trigger 'before_submit'
          custom_test = @client.get "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=0000"
          res_page = custom_test.form_with(:action => '/onlinejudge/servlet/Submit') do |form|
            form.userID = config["user"]
            form.password = config["password"]
            form.problemNO = problem_id
            form.language = "Ruby"
            form.sourceCode = File.read(source_path)
          end.submit
          trigger 'after_submit'

          # need to get the newest waiting submissionId
          submission_id = get_submission_id(res_page.body)

          # wait result
          trigger 'before_wait',
          trigger 'after_wait'
          trigger 'finish'
          return -1
        end
      end
    end
  end
end
