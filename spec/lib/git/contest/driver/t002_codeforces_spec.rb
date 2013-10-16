require 'spec_helper'

require 'git/contest/driver/codeforces'
require 'mechanize'

describe "T002: Git::Contest::Driver::Codeforces" do
  before do
    @driver = Git::Contest::Driver::Codeforces.new
    @driver.stub(:sleep).and_return(0)
    @driver.client = Mechanize.new {|agent|
      agent.user_agent_alias = 'Windows IE 7'
    }

    # basic status_log
    WebMock.stub_request(
      :get,
      /http:\/\/codeforces.com\/contest\/[0-9A-Z]*\/my/
    ).to_return(
      :status => 200,
      :body => read_file('/mock/t002/my_submissions.html'),
      :header => {
        'Content-Type' => 'text/html',
      },
    )
  end

  describe '001: #get_status_wait' do
    it '001: Check Status' do
      ret = @driver.get_status_wait 11111, 22222
      ret.should === "Accepted"
    end
  end
end

