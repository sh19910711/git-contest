require "spec_helper"

describe "T006: Config Test" do

  before do
    init_env
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t006"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
    ENV['GIT_CONTEST_DEBUG'] = 'ON'
  end

  after do
    Dir.chdir '..'
    Dir.rmdir @test_dir
  end

  describe "001: submit" do

    describe "001: commit_message" do

      before do
        Dir.mkdir '001'
        Dir.chdir '001'
        File.open "main.d", "w" do |file|
          file.write "ac-code"
        end
        bin_exec "init --defaults"
      end

      after do
        FileUtils.remove_dir ".git", :force => true
        FileUtils.remove "main.d"
        Dir.chdir '..'
        Dir.rmdir '001'
      end

      it "001: ${site} ${problem-id}: ${status}" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/001/001/config.yml')
        ret = bin_exec "submit test_dummy -c 100 -p A"
        ret.include?('Dummy 100A: Accepted').should === true
      end

      it "002: ${site}-${problem-id}-${status}" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/001/002/config.yml')
        ret = bin_exec "submit test_dummy -c 100 -p A"
        ret.include?('Dummy-100A-Accepted').should === true
      end

      it "003: ${status}-${site}" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/001/003/config.yml')
        ret = bin_exec "submit test_dummy -c 100 -p A"
        ret.include?('Accepted-Dummy').should === true
      end

    end

  end

end

