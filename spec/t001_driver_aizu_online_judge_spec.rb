require 'spec_helper'

require 'mechanize'
require 'git/contest/driver/aizu_online_judge'

describe "T001: Git::Contest::Driver::AizuOnlineJudge" do
  before do
    # setup
    @driver = Git::Contest::Driver::AizuOnlineJudge.new
    @driver.stub(:sleep).and_return(0)
    @driver.client = Mechanize.new {|agent|
      agent.user_agent_alias = 'Windows IE 7'
    }

    # basic status_log
    WebMock.stub_request(
      :get,
      /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log\??.*/
    ).to_return(
      :status => 200,
      :body => read_file('/mock/t001.status_log.xml'),
      :header => {
        'Content-Type' => 'text/xml',
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
  end

  describe "002: #get_status_wait" do
    before do
      # has 2 statuses
      WebMock.stub_request(
        :get,
        /http:\/\/judge\.u-aizu\.ac\.jp\/onlinejudge\/webservice\/status_log\??.*/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t001_002.status_log.xml'),
        :header => {
          'Content-Type' => 'text/xml',
        },
      )
    end
    it "001: Check Status" do
      ret = @driver.get_status_wait 'test_user', '111'
      ret.should === "Wrong Answer"
    end
  end
end

