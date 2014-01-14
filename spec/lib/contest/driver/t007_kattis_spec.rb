require "spec_helper"
require "contest/driver/kattis"

describe "T007: Kattis Driver" do
  before do
    @driver = Contest::Driver::Kattis.new
  end

  context "A001: #get_submission_id" do
    subject do
      dummy_html = read_file('/mock/t007/user_submissions.html')
      @driver.get_submission_id dummy_html
    end
    it "must return last submission id" do
      should eq "111111"
    end
  end

  context "A002: #get_submissions_status" do
    context "111111" do
      subject do
        dummy_html = read_file('/mock/t007/user_submissions.html')
        @driver.get_submission_status "111111", dummy_html
      end
      it "must return the status of specified submission" do
        should eq "Accepted"
      end
    end
    context "222222" do
      subject do
        dummy_html = read_file('/mock/t007/user_submissions.html')
        @driver.get_submission_status "222222", dummy_html
      end
      it "must return the status of specified submission" do
        should eq "Wrong Answer"
      end
    end
  end
end

