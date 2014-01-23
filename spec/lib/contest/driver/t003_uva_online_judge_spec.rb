require 'spec_helper'

require 'contest/driver/codeforces'
require 'mechanize'

describe "T003: UvaOnlineJudge Driver" do
  before :each do
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t003"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after :each do
    Dir.chdir @test_dir
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  before(:each) do
    @driver = Contest::Driver::UvaOnlineJudge.new
    @driver.stub(:sleep).and_return(0)
  end

  context "A001: #get_submission_id" do
    it "should return last submission id" do
      ret = @driver.get_submission_id(read_file('/mock/t003/after_submit.html'))
      ret.should eq '99999'
    end
  end

  context "A002: #get_submission_status" do
    it "Sent to judge" do
      ret = @driver.get_submission_status('99999', read_file('/mock/t003/my_submissions.sent_to_judge.html'))
      ret.should eq 'Sent to judge'
    end

    it "Compilation error" do
      ret = @driver.get_submission_status('99999', read_file('/mock/t003/my_submissions.compile_error.html'))
      ret.should eq 'Compilation error'
    end
  end

  context "A003: #submit" do
    before do
      FileUtils.touch 'test_source.java'
    end

    before do
      # index.html
      WebMock
      .stub_request(
        :get,
        /^http:\/\/uva\.onlinejudge\.org\/$/,
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t003/uva_home.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # login
      WebMock
      .stub_request(
        :post,
        /^http:\/\/uva\.onlinejudge\.org\/index\.php\?option=com_comprofiler&task=login$/,
      )
      .to_return(
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # quick submit page
      WebMock
      .stub_request(
        :get,
        /^http:\/\/uva\.onlinejudge\.org\/index\.php\?Itemid=25&option=com_onlinejudge$/,
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t003/uva_quick_submit.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # quick submit
      WebMock
      .stub_request(
        :post,
        /^http:\/\/uva\.onlinejudge\.org\/index\.php\?Itemid=25&option=com_onlinejudge&page=save_submission$/,
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t003/uva_after_quick_submit.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # status
      WebMock
      .stub_request(
        :get,
        /^http:\/\/uva\.onlinejudge\.org\/index\.php\?Itemid=9&option=com_onlinejudge$/
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t003/uva_my_submissions.html'),
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
        :problem_id => '333333',
        :source => 'test_source.java',
      )
      @driver.submit.should include "UVa 333333: Wrong answer"
    end

    it "Check events" do
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
        :problem_id => '333333',
        :source => 'test_source.java',
      )
      @driver.submit()

      @flag = @flag_start && @flag_before_submit && @flag_after_submit && @flag_before_wait && @flag_after_wait && @flag_finish
      @flag.should === true
    end
  end

  context "A004: #is_wait_status" do
    context "wait" do
      it "Sent to judge" do
        @driver.is_wait_status("Sent to judge").should be true
      end
      it "Running" do
        @driver.is_wait_status("Running").should be true
      end
      it "Compiling" do
        @driver.is_wait_status("Running").should be true
      end
      it "Linking" do
        @driver.is_wait_status("Linking").should be true
      end
      it "Received" do
        @driver.is_wait_status("Received").should be true
      end
    end
    context "no wait" do
      it "Accepted" do
        @driver.is_wait_status("Accepted").should be false
      end
      it "Compilation error" do
        @driver.is_wait_status("Compilation error").should be false
      end
      it "Wrong answer" do
        @driver.is_wait_status("Wrong answer").should be false
      end
      it "Runtime error" do
        @driver.is_wait_status("Runtime error").should be false
      end
    end
  end
end

