require 'git/contest/common'
require 'git/contest/driver/common'

module Git
  module Contest
    module Driver
      class UvaOnlineJudge < DriverEvent
        def get_opts
          opts = Trollop::options do
            opt(
              :problem_id,
              "Problem ID (Ex: 100, 200, etc...)",
              :type => :string,
              :required => true,
            )
          end
          return opts
        end

        def get_desc
          "UVa Online Judge (URL: http://uva.onlinejudge.org/)"
        end

        def submit(config, source_path, options)
          trigger 'start'
          problem_id = options[:problem_id]

          @client = Mechanize.new {|agent|
            agent.user_agent_alias = 'Windows IE 7'
          }

          # submit
          trigger 'before_login'
          login_page = @client.get 'http://uva.onlinejudge.org/'
          login_page.form_with(:id => 'mod_loginform') do |form|
            form.username = config["user"]
            form.passwd = config["password"]
          end.submit
          trigger 'after_login'

          trigger 'before_submit'
          submit_page = @client.get 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=25'
          res_page = submit_page.form_with(:action => 'index.php?option=com_onlinejudge&Itemid=25&page=save_submission') do |form|
            form.localid = problem_id
            form.radiobutton_with(:name => 'language', :value => '3').check
            form.code = File.read(source_path)
          end.submit
          trigger 'after_submit'

          # <div class="message">Submission received with ID 12499981</div>
          trigger 'before_wait'
          submission_id = get_submission_id(res_page.body)
          status = get_status_wait(submission_id)
          trigger(
            'after_wait',
            {
              :submission_id => submission_id,
              :status => status,
            }
          )

          trigger 'finish'
          return "UVa %s: #{status}\nsubmission_id = #{submission_id}" % [problem_id]
        end

        def get_status_wait(submission_id)
          submission_id = submission_id.to_s
          # wait result
          12.times do
            sleep 5
            my_page = @client.get 'http://uva.onlinejudge.org/index.php?option=com_onlinejudge&Itemid=9'
            status = get_submission_status(submission_id, my_page.body)
            return status unless status == 'Sent to judge' || status == ''
            trigger 'retry'
          end
          trigger 'timeout'
          return 'timeout'
        end

        def get_submission_id(body)
          doc = Nokogiri::HTML(body)
          text = doc.xpath('//div[@class="message"]')[0].text().strip
          # Submission received with ID 12500010
          text.match(/Submission received with ID ([0-9]+)/)[1]
        end

        def get_submission_status(submission_id, body)
          doc = Nokogiri::HTML(body)
          doc.xpath('//tr[@class="sectiontableheader"]/following-sibling::node()').search('tr').each do |elm|
            td_list = elm.search('td')
            item_submission_id = td_list[0].text.strip
            if item_submission_id == submission_id
              item_problem_id = td_list[1].text.strip
              item_status = td_list[3].text.strip
              return item_status
            end
          end
          'timeout'
        end

        if ENV['TEST_MODE'] === 'TRUE'
          attr_writer :client
        else
        end
      end
    end
  end
end