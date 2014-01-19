require 'spec_helper'

require 'contest/driver/codeforces'
require 'mechanize'

describe "T002: Codeforces Driver" do
  before :each do
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t002"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after :each do
    Dir.chdir @test_dir
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  before(:each) do
    @driver = Contest::Driver::Codeforces.new
    @driver.stub(:sleep).and_return(0)
  end

  context "A001: #get_status_wait" do
    before do
      # basic status_log
      WebMock.stub_request(
        :get,
        /http:\/\/codeforces.com\/contest\/[0-9A-Z]*\/my/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t002/my_submissions.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      @driver.client = Mechanize.new {|agent|
        agent.user_agent_alias = 'Windows IE 7'
      }
    end

    it "check status" do
      ret = @driver.get_status_wait 11111, 22222
      ret.should include "Accepted"
    end
  end

  context "A002: #submit" do
    before do
      FileUtils.touch 'test_source.rb'

      # basic status_log
      WebMock.stub_request(
        :get,
        /http:\/\/codeforces.com\/contest\/222222\/my/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t002/codeforces_wait_result.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # basic status_log
      WebMock.stub_request(
        :get,
        /http:\/\/codeforces.com\/enter/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t002/codeforces_enter.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # enter page
      WebMock.stub_request(
        :post,
        /http:\/\/codeforces.com\/enter/
      ).to_return(
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # submit
      WebMock.stub_request(
        :get,
        /http:\/\/codeforces.com\/contest\/[0-9]*\/submit/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t002/codeforces_submit.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # submit
      WebMock.stub_request(
        :post,
        /http:\/\/codeforces.com\/contest\/[0-9]*\/submit.*/
      ).to_return(
        :status => 302,
        :headers => {
          'Content-Type' => 'text/html',
          'Location' => 'http://codeforces.com/after_submit',
        },
      )

      # problemst status
      WebMock.stub_request(
        :get,
        /http:\/\/codeforces.com\/after_submit/
      ).to_return(
        :status => 200,
        :body => read_file('/mock/t002/codeforces_after_submit.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )
    end

    it "should return commit message" do
      @driver.config.merge!(
        "user" => "test_user",
        "password" => "password",
      )
      @driver.options.merge!(
        :contest_id => '222222',
        :problem_id => 'A',
        :source => 'test_source.rb',
      )
      @driver.submit.should include "Codeforces 222222A: Accepted"
    end

    it "check events" do
      @flag_start         = false
      @flag_before_login  = false
      @flag_after_login   = false
      @flag_before_submit = false
      @flag_after_submit  = false
      @flag_before_wait   = false
      @flag_after_wait    = false
      @flag_finish        = false

      proc_start = Proc.new do
        @flag_start = true
      end
      proc_before_login = Proc.new do |info|
        @flag_before_login = true
      end
      proc_after_login = Proc.new do
        @flag_after_login = true
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
      @driver.on 'before_login', proc_before_login
      @driver.on 'after_login', proc_after_login
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
        :contest_id => '222222',
        :problem_id => 'A',
        :source => 'test_source.rb',
      )

      @driver.submit

      @flag = @flag_start && @flag_before_login && @flag_after_login && @flag_before_submit && @flag_after_submit && @flag_before_wait && @flag_after_wait && @flag_finish
      @flag.should === true
    end
  end
end

