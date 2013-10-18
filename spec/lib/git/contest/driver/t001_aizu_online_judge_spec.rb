require 'spec_helper'

require 'mechanize'
require 'git/contest/driver/aizu_online_judge'

describe "T001: Git::Contest::Driver::AizuOnlineJudge" do
  before do
    # setup driver
    @driver = Git::Contest::Driver::AizuOnlineJudge.new
    @driver.stub(:sleep).and_return(0)
    @driver.client = Mechanize.new {|agent|
      agent.user_agent_alias = 'Windows IE 7'
    }
    ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t001/config.yml')
    init

    # basic status_log
    WebMock
    .stub_request(
      :get,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log/,
    )
    .to_return(
      :status => 200,
      :body => read_file('/mock/t001/status_log.xml'),
      :headers => {
        'Content-Type' => 'text/xml',
      },
    )

    # status.jsp: http://judge.u-aizu.ac.jp/onlinejudge/status.jsp
    WebMock
    .stub_request(
      :get,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/status/,
    )
    .to_return(
      :status => 200,
      :body => read_file('/mock/t001/status.html'),
      :headers => {
        'Content-Type' => 'text/html',
      },
    )

    # description
    WebMock
    .stub_request(
      :get,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/description\.jsp\?id=/,
    )
    .to_return(
      :status => 200,
      :body => read_file('/mock/t001/description.html'),
      :headers => {
        'Content-Type' => 'text/html',
      },
    )

    # servlet/Submit
    WebMock
    .stub_request(
      :post,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/servlet\/Submit/,
    )
    .to_return(
      :status => 200,
      :body => '',
      :headers => {
        'Content-Type' => 'text/html',
      },
    )
  end

  describe "001: #get_status_wait" do
    it "001: Check Status" do
      ret = @driver.get_status_wait 'test_user', '111'
      ret.should === "Wrong Answer"
    end
    it "002: Check Timeout" do
      @flag = false
      proc = Proc.new do
        @flag = true
      end
      @driver.on 'timeout', proc
      @driver.get_status_wait 'test_user', '999'
      @driver.off 'timeout', proc
      @flag.should === true
    end
    it "002: Check Timeout noset" do
      @flag = false
      proc = Proc.new do
        @flag = true
      end
      @driver.on 'timeout', proc
      @driver.off 'timeout', proc
      @driver.get_status_wait 'test_user', '999'
      @flag.should === false
    end
  end

  describe "002: #get_status_wait" do
    before do
      # has 2 statuses
      WebMock.stub_request(
        :get,
        /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log\??.*/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t001/002.status_log.xml'),
        :headers => {
          'Content-Type' => 'text/xml',
        },
      )
    end
    it "001: Check Status" do
      ret = @driver.get_status_wait 'test_user', '111'
      ret.should === "Wrong Answer"
      ret = @driver.get_status_wait 'test_user', '112'
      ret.should === "Accepted"
    end
  end

  describe "003: #submit" do
    it "001: Check Event" do
      File.write '/tmp/main.rb', ''

      @flag_start         = false
      @flag_before_submit = false
      @flag_after_submit  = false
      @flag_before_wait   = false
      @flag_after_wait    = false
      @flag_finish        = false

      proc_start = Proc.new do
        @flag_start = true
      end
      proc_before_submit = Proc.new do |info|
        @flag_before_submit = true
      end
      proc_after_submit = Proc.new do
        @flag_after_submit = true
      end
      proc_before_wait = Proc.new do
        @flag_before_wait = true
      end
      proc_after_wait = Proc.new do
        @flag_after_wait = true
      end
      proc_finish = Proc.new do
        @flag_finish = true
      end

      @driver.on 'start', proc_start
      @driver.on 'before_submit', proc_before_submit
      @driver.on 'after_submit', proc_after_submit
      @driver.on 'before_wait', proc_before_wait
      @driver.on 'after_wait', proc_after_wait
      @driver.on 'finish', proc_finish

      @driver.submit(
        {
          "user" => "test_user",
          "password" => "password",
        },
        '/tmp/main.rb',
        {
          :contest_id => '11111',
          :problem_id => '22222',
        },
      )

      @flag = @flag_start && @flag_before_submit && @flag_after_submit && @flag_before_wait && @flag_after_wait && @flag_finish
      @flag.should === true
    end
  end
end

