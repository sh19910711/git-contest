require "spec_helper"

describe "T010: Kattis Driver" do
  before do
    @driver = Contest::Driver::KattisDriver.new
    @driver.stub(:sleep).and_return(0)
  end

  context "A001: #get_submission_id" do
    subject do
      dummy_html = read_file('/mock/t010/user_submissions.html')
      @driver.get_submission_id dummy_html
    end
    it "must return last submission id" do
      should eq "111111"
    end
  end

  context "A002: #get_submissions_status" do
    context "111111" do
      subject do
        dummy_html = read_file('/mock/t010/user_submission_111111.html')
        @driver.get_submission_status "111111", dummy_html
      end
      it "must return the status of specified submission" do
        should eq "Accepted"
      end
    end
    context "222222" do
      subject do
        dummy_html = read_file('/mock/t010/user_submission_222222.html')
        @driver.get_submission_status "222222", dummy_html
      end
      it "must return the status of specified submission" do
        should eq "Wrong Answer"
      end
    end
  end

  context "A003: #submit" do
    before do
      FileUtils.touch 'test_source.go'
    end

    before do
      # login page
      WebMock.stub_request(
        :get,
        /^https:\/\/open\.kattis\.com\/login\?email_login=true$/
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t010/open_kattis_com_login.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # login
      WebMock.stub_request(
        :post,
        /^https:\/\/open\.kattis\.com\/login\/email$/
      )
      .to_return(
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # submit page
      WebMock.stub_request(
        :get,
        /^https:\/\/open\.kattis\.com\/submit$/,
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t010/open_kattis_com_submit.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # submit
      WebMock.stub_request(
        :post,
        /^https:\/\/open\.kattis\.com\/submit$/,
      )
      .to_return(
        :status => 200,
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # user submissions
      WebMock.stub_request(
        :get,
        /^https:\/\/open\.kattis\.com\/users\/test_user$/
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t010/open_kattis_com_user_submissions.html'),
        :headers => {
          'Content-Type' => 'text/html',
        },
      )

      # submission 999999
      WebMock.stub_request(
        :get,
        /^https:\/\/open\.kattis\.com\/submissions\/999999$/
      )
      .to_return(
        :status => 200,
        :body => read_file('/mock/t010/open_kattis_com_user_submissions.html'),
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
        :source => 'test_source.go',
      )
      expect(@driver.submit).to include "Kattis 333333: Wrong Answer"
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
        :problem_id => '333333',
        :source => 'test_source.go',
      )
      @driver.submit

      @flag = @flag_start && @flag_before_login && @flag_after_login && @flag_before_submit && @flag_after_submit && @flag_before_wait && @flag_after_wait && @flag_finish
      expect(@flag).to be true
    end
  end
end
