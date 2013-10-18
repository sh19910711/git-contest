require "spec_helper"

describe "T007: git-contest-start" do

  before do
    init_env
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t007"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after do
    Dir.chdir '..'
    Dir.rmdir @test_dir
  end

  describe "001: specify based branch" do

    before do
      Dir.mkdir "001"
      Dir.chdir "001"
      bin_exec "init --defaults"
    end

    after do
      FileUtils.remove_dir '.git', :force => true
      Dir.chdir ".."
      Dir.rmdir "001"
    end

    it "001" do
      git_do "branch -b base1"
      git_do "commit --allow-empty -m 'this is commit'"
      git_do "checkout master"
      bin_exec "start test1"
      ret1 = git_do "log --oneline"
      ret1.include?("this is commit").should === false
      bin_exec "start test2 base1"
      ret2 = git_do "log --oneline"
      ret2.include?("this is commit").should === true
    end

    it "002" do
      git_do "branch -b base1"
      git_do "commit --allow-empty -m 'this is commit'"
      git_do "checkout master"
      bin_exec "start test1 base1"
      ret1 = git_do "log --oneline"
      ret1.include?("this is commit").should === true
      bin_exec "start test2"
      ret2 = git_do "log --oneline"
      ret2.include?("this is commit").should === false
    end

  end

  describe "002: --fetch" do

    before do
      Dir.mkdir "002"
      Dir.chdir "002"
    end

    after do
      FileUtils.remove_dir '.git', :force => true
      Dir.chdir ".."
      Dir.rmdir "002"
    end

    it "001" do
      Dir.mkdir "test1"
      Dir.chdir "test1"
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x| git_do "commit --allwo-empty -m 'this is commit'" }
      Dir.chdir ".."
      git_do "clone test1 test2"
      Dir.chdir "test2"

      # fetch
      ret = git_do "log --oneline"
      ret.include?("this is commit").should === false
      git_do "start branch1 --fetch"
      ret = git_do "log --oneline"
      ret.include?("this is commit").should === true

      # clean
      Dir.chdir ".."
      FileUtils.remove_dir "test1/.git", :force => true
      FileUtils.remove_dir "test2/.git", :force => true
      Dir.rmdir "test1"
      Dir.rmdir "test2"
    end

  end

end

