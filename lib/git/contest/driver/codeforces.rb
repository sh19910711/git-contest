require 'git/contest/common'
require 'git/contest/driver/common'

module Git
  module Contest
    module Driver
      class Codeforces < DriverEvent
        def get_opts
          opts = Trollop::options do
            opt(
              :contest_id,
              "Contest ID (Ex: 100, 234, etc...)",
              :type => :string,
              :required => true,
            )
            opt(
              :problem_id,
              "Problem ID (Ex: A, B, etc...)",
              :type => :string,
              :required => true,
            )
          end
          return opts
        end

        def get_desc
          "Codeforces (URL: http://codeforces.com/)"
        end

        def submit(config, source_path, options)
          # start
          trigger 'start'
          contest_id = options[:contest_id]
          problem_id = options[:problem_id]

          @client = Mechanize.new {|agent|
            agent.user_agent_alias = 'Windows IE 7'
          }

          # login
          trigger 'before_login'
          login_page = @client.get 'http://codeforces.com/enter'
          login_page.form_with(:action => '') do |form|
            form.handle = config["user"]
            form.password = config["password"]
          end.submit
          trigger 'after_login'

          # submit
          trigger 'before_submit'
          custom_test = @client.get "http://codeforces.com/contest/#{contest_id}/submit"
          res_page = custom_test.form_with(:class => 'submit-form') do |form|
            form.submittedProblemIndex = problem_id
            form.programTypeId = "8"
            form.source = File.read(source_path)
          end.submit
          trigger 'after_submit'

          # need to get the newest waiting submissionId
          trigger 'before_wait',
          submission_id = get_submission_id(res_page.body)

          # wait result
          status = get_status_wait(contest_id, submission_id)
          trigger(
            'after_wait',
            {
              :submission_id => submission_id,
              :status => status,
            }
          )

          trigger 'finish'
          return "Codeforces %s%s: #{status}\nhttp://codeforces.com/contest/#{contest_id}/submission/#{submission_id}" % [contest_id, problem_id]
        end

        def get_status_wait(contest_id, submission_id)
          contest_id = contest_id.to_s
          submission_id = submission_id.to_s
          # wait result
          5.times do
            sleep 3
            my_page = @client.get "http://codeforces.com/contest/#{contest_id}/my"
            status = get_status(submission_id, my_page.body)
            return status unless is_waiting(submission_id, my_page.body)
            trigger 'retry'
          end
          trigger 'timeout'
          return 'timeout'
        end

        def is_waiting(submission_id, body)
          doc = Nokogiri::HTML(body)
          element = doc.xpath('//td[@submissionid="' + submission_id + '"]')[0]
          element["waiting"] == "true"
        end

        def get_status(submission_id, body)
          doc = Nokogiri::HTML(body)
          element = doc.xpath('//td[@submissionid="' + submission_id + '"]')[0]
          element.text().strip
        end

        def get_submission_id(body)
          doc = Nokogiri::HTML(body)
          elements = doc.xpath('//td[contains(concat(" ",@class," "), " status-cell ")][@waiting="true"]')
          elements[0].attributes()["submissionid"].value.strip
        end

        if ENV['TEST_MODE'] === 'TRUE'
          attr_writer :client
        else
          private :get_status_wait
          private :is_waiting
          private :get_status
          private :get_submission_id
        end
      end
    end
  end
end
