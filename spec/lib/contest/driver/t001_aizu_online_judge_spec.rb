require 'spec_helper'

describe "T001: AizuOnlineJudge Driver" do 
  before do
    # setup driver
    @driver = Contest::Driver::AizuOnlineJudge.new
    @driver.stub(:sleep).and_return(0)
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
      ret = @driver.send :get_status_wait, 'test_user', '111'
      expect(ret).to eq "Wrong Answer"
    end

    it "002: Check Timeout" do
      @flag = false
      proc = Proc.new do
        @flag = true
      end
      @driver.on 'timeout', proc
      @driver.send :get_status_wait, 'test_user', '999'
      @driver.off 'timeout', proc
      expect(@flag).to eq true
    end

    it "002: Check Timeout noset" do
      @flag = false
      proc = Proc.new do
        @flag = true
      end
      @driver.on 'timeout', proc
      @driver.off 'timeout', proc
      @driver.send :get_status_wait, 'test_user', '999'
      expect(@flag).to eq false
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
      ret = @driver.send :get_status_wait, 'test_user', '111'
      expect(ret).to eq "Wrong Answer"
      ret = @driver.send :get_status_wait, 'test_user', '112'
      expect(ret).to eq "Accepted"
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
      expect(@flag).to eq true
    end
  end

  context "A004: #normalize_problem_id" do
    it "1234" do
      expect(@driver.send(:normalize_problem_id, "1234")).to eq "1234"
    end
    it "0240" do
      expect(@driver.send(:normalize_problem_id, "0240")).to eq "0240"
    end
    it "10000" do
      expect(@driver.send(:normalize_problem_id, "10000")).to eq "10000"
    end
  end
end

