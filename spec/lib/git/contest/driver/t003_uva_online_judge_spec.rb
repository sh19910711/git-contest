require 'spec_helper'

require 'git/contest/driver/codeforces'
require 'mechanize'

describe "T003: Git::Contest::Driver::UvaOnlineJudge" do
  before do
    @driver = Git::Contest::Driver::UvaOnlineJudge.new
    @driver.stub(:sleep).and_return(0)
    @driver.client = Mechanize.new {|agent|
      agent.user_agent_alias = 'Windows IE 7'
    }
  end

  describe '001: #get_submission_id' do
    it '001' do
      ret = @driver.get_submission_id(read_file('/mock/t003/after_submit.html'))
      ret.should eq '99999'
    end
  end

  describe '002: #get_submission_status' do
    it '001: Sent to Judge' do
      ret = @driver.get_submission_status('99999', read_file('/mock/t003/my_submissions.sent_to_judge.html'))
      ret.should eq 'Sent to judge'
    end
    it '002: Compile Error' do
      ret = @driver.get_submission_status('99999', read_file('/mock/t003/my_submissions.compile_error.html'))
      ret.should eq 'Compilation error'
    end
  end
end

