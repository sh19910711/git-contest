require "spec_helper"

describe "T005" do

  before(:each) do
    init_env
    ENV['GIT_CONTEST_HOME'] = get_path('/mock/default_config')
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t005"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
    # ENV['GIT_CONTEST_DEBUG'] = 'ON'
  end

  after(:each) do
    Dir.chdir '..'
    FileUtils.remove_dir @test_dir, :force => true
  end

  describe "001" do

    before do
      ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t005/001/config.yml')
      Dir.mkdir '001'
      Dir.chdir '001'
    end

    describe '001' do

      before do
        Dir.mkdir '001'
        Dir.chdir '001'
      end

      it '001: init -> start -> submit -> submit -> finish' do
        Dir.mkdir 'test1'
        Dir.chdir 'test1'
        # Init
        bin_exec "init --defaults"
        git_current_branch.should === 'master'
        ret = git_do "log --oneline"
        ret.include?('Initial commit').should === true
        # Start
        bin_exec "start contest1"
        git_current_branch.should === 'contest/contest1'
        # Edit.1
        File.open 'main.c', 'w' do |file|
          file.write 'wa-code'
        end
        # Submit.1
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Wrong Answer').should === true
        ret = git_do "ls-files"
        ret.include?('main.c').should === true
        # Edit.2 fixed
        File.open 'main.c', 'w' do |file|
          file.write 'ac-code'
        end
        # Submit.2
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Accepted').should === true
        ret = git_do "ls-files"
        ret.include?('main.c').should === true
        # Finish
        bin_exec "finish --no-edit"
        git_current_branch.should === 'master'
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Wrong Answer').should === true
        ret.include?('Dummy 1000A: Accepted').should === true
        # Clean
        FileUtils.remove_dir '.git', :force => true
        FileUtils.remove 'main.c'
        Dir.chdir '..'
        Dir.rmdir 'test1'
      end

    end

  end

end

