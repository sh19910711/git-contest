require 'spec_helper'

require 'mechanize'
require 'contest/driver/aizu_online_judge'

describe "T001: AizuOnlineJudge Driver" do
  before :each do
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t001"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after :each do
    Dir.chdir @test_dir
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  before do
    # setup driver
    @driver = Contest::Driver::AizuOnlineJudge.new
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

  end

  context "A001: #get_status_wait" do
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

  context "A002: #get_status_wait" do
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

  context "A003: #submit" do
    before do
      FileUtils.touch 'test_source.rb'

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

    it "001: Check Event" do
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

      @driver.config.merge!(
        "user" => "test_user",
        "password" => "password",
      )
      @driver.options.merge!(
        :contest_id => '11111',
        :problem_id => '22222',
        :source => 'test_source.rb',
      )
      @driver.submit()

      @flag = @flag_start && @flag_before_submit && @flag_after_submit && @flag_before_wait && @flag_after_wait && @flag_finish
      @flag.should === true
    end
  end
end

