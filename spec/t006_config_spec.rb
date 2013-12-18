require "spec_helper"

describe "T006: Config Test" do

  before do
    init_env
    ENV['GIT_CONTEST_HOME'] = get_path('/mock/default_config')
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t006"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
    # debug_on
  end

  after do
    Dir.chdir '..'
    Dir.rmdir @test_dir
  end

  describe "001: submit_rules" do

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
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret1.include?('Dummy 100A: Accepted').should === true
      end

      it "002: ${site}-${problem-id}-${status}" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/001/002/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret1.include?('Dummy-100A-Accepted').should === true
      end

      it "003: ${status}-${site}" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/001/003/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret1.include?('Accepted-Dummy').should === true
      end

    end

    describe "002: source" do

      before do
        Dir.mkdir '002'
        Dir.chdir '002'
        File.open "ac.cpp", "w" do |file|
          file.write "ac-code"
        end
        File.open "wa.d", "w" do |file|
          file.write "wa-code"
        end
        File.open "tle.go", "w" do |file|
          file.write "tle-code"
        end
        bin_exec "init --defaults"
      end

      after do
        FileUtils.remove_dir ".git", :force => true
        FileUtils.remove "ac.cpp"
        FileUtils.remove "wa.d"
        FileUtils.remove "tle.go"
        Dir.chdir '..'
        Dir.rmdir '002'
      end

      it "001: ac.*" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/002/001/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Accepted').should === true
        ret_ls1.include?('ac.cpp').should === true
      end

      it "002: wa.*" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/002/002/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Wrong Answer').should === true
        ret_ls1.include?('wa.d').should === true
      end

      it "003: tle.*" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/002/003/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Time Limit Exceeded').should === true
        ret_ls1.include?('tle.go').should === true
      end

    end

    describe "003: add" do

      before do
        Dir.mkdir '003'
        Dir.chdir '003'
        File.open "test1.cpp", "w" do |file|
          file.write "ac-code"
        end
        File.open "input1.txt", "w" do |file|
          file.write "test"
        end
        File.open "test2.c", "w" do |file|
          file.write "wa-code"
        end
        File.open "input2.txt", "w" do |file|
          file.write "test2"
        end
        bin_exec "init --defaults"
      end
      
      after do
        FileUtils.remove_dir '.git'
        FileUtils.remove "test1.cpp"
        FileUtils.remove "input1.txt"
        FileUtils.remove "test2.c"
        FileUtils.remove "input2.txt"
        Dir.chdir ".."
        Dir.rmdir "003"
      end

      it "001: test*.cpp input1.txt" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/003/001/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === true
        ret1.include?("input1.txt").should === true
        ret1.include?("test2.c").should    === false
        ret1.include?("input2.txt").should === false
      end

      it "002: input2.txt test*.c" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/003/002/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === false
        ret1.include?("input1.txt").should === false
        ret1.include?("test2.c").should    === true
        ret1.include?("input2.txt").should === true
      end

      it "003: input1.txt test1.cpp test2.c input2.txt" do
        ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t006/001/003/003/config.yml')
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === true
        ret1.include?("input1.txt").should === true
        ret1.include?("test2.c").should    === true
        ret1.include?("input2.txt").should === true
      end

    end

  end

end

