require 'git/contest/common'
require 'git/contest/driver/common'

module Git
  module Contest
    module Driver
      class Codeforces < DriverBase 
        def get_opts_ext
          define_options do
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
        end

        def get_desc
          "Codeforces (URL: http://codeforces.com/)"
        end

        def resolve_language(label)
          case label
          when "c", "C"
            return "10"
          when "cpp", "C++", "c++"
            return "1"
          when "c++11", "C++11"
            return "16"
          when "cs", "c#", "C#"
            return "9"
          when "d", "D", "dlang"
            return "28"
          when "go", "golang"
            return "32"
          when "hs", "haskell", "Haskell"
            return "12"
          when "java", "Java"
            return "23"
          when "ocaml", "ml", "OCaml"
            return "19"
          when "Delphi", "delphi"
            return "3"
          when "pascal", "Pascal"
            return "4"
          when "perl", "Perl", "pl"
            return "13"
          when "php", "PHP"
            return "6"
          when "python2"
            return "7"
          when "python3", "python", "Python", "py"
            return "31"
          when "ruby", "rb", "Ruby"
            return "8"
          when "scala", "Scala"
            return "20"
          else
            abort "unknown languag"
          end
        end

        def submit_ext(config, source_path, options)
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
            form.programTypeId = options[:language]
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
