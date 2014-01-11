#
# uva_online_judge.rb
#
# Copyright (c) 2013 Hiroyuki Sano <sh19910711 at gmail.com>
# Licensed under the MIT-License.
#

require 'contest/driver/common'

module Contest
  module Driver
    class Kattis < DriverBase
      def get_opts_ext
        define_options do
          opt(
            :problem_id,
            "Problem ID (Ex: 100, 200, etc...)",
            :type => :string,
            :required => true,
          )
        end
      end

      def get_site_name
        "Kattis"
      end

      def get_desc
        "Kattis (URL: https://open.kattis.com/)"
      end

      def resolve_language(label)
        case label
        when "cpp"
          return "1"
        when "c"
          return "2"
        when "java"
          return "3"
        when "python2"
          return "6"
        when "python3"
          return "8"
        when "cs"
          return "9"
        when "golang"
          return "10"
        #when "objectivec"
        #  return "11"
        else
          abort "unknown language"
        end
      end

      def submit_ext(config, source_path, options)
        trigger 'start'
        problem_id = options[:problem_id]

        @client = Mechanize.new {|agent|
          agent.user_agent_alias = 'Windows IE 7'
        }

        # submit
        trigger 'before_login'
        login_page = @client.get 'https://open.kattis.com/login?email_login=true'
        page = login_page.form_with(:action => 'login?email_login=true') do |form|
          form.user = config["user"]
          form.password = config["password"]
        end.submit
        print page.body
        trigger 'after_login'

        trigger 'before_submit', options
        submit_page = @client.get 'https://open.kattis.com/submit'
        res_page = submit_page.form_with(:action => 'submit') do |form|
          form['problem'] = problem_id
          form.lang = options[:language]
          form.sub_code = File.read(source_path)
          # form['mainclass'] = 'Main'
        end.submit
        print res_page.body
        trigger 'after_submit'

        # result
        trigger 'before_wait'
        #submission_id = get_submission_id(res_page.body)
        #status = get_status_wait(submission_id)
        #trigger(
        #  'after_wait',
        #  {
        #    :submission_id => submission_id,
        #    :status => status,
        #    :result => get_commit_message($config["submit_rules"]["message"], status, options),
        #  }
        #)

        trigger 'finish'
        # get_commit_message($config["submit_rules"]["message"], status, options)
      end

      def get_status_wait(submission_id)
        submission_id = submission_id.to_s
        # wait result
        12.times do
          sleep 10
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

      if is_test_mode?
        attr_writer :client
      else
      end
    end
  end
end
