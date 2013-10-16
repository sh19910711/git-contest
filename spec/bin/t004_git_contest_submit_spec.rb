require "spec_helper"

describe "T004: bin/git-contest-submit" do

  before do
    init_env
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t004"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after do
    Dir.chdir '..'
    Dir.rmdir @test_dir
  end

  describe "001: version option check" do

    it "001: git-contest-submit --version" do
      ret = `#{bin_path("git-contest-submit")} --version`
      (!!ret.match(/git-contest [0-9]+\.[0-9]+\.[0-9]+/)).should === true
    end

    it "002: git-contest submit --version" do
      ret = `#{bin_path("git-contest submit")} --version`
      (!!ret.match(/git-contest [0-9]+\.[0-9]+\.[0-9]+/)).should === true
    end

    it "003: git contest submit --version" do
      ret = `git contest submit --version`
      (!!ret.match(/git-contest [0-9]+\.[0-9]+\.[0-9]+/)).should === true
    end

  end

  describe "002: help check" do

    before do
      ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t004/config.yml')
      Dir.mkdir '002'
      Dir.chdir '002'
      Dir.mkdir 'working'
      Dir.chdir 'working'
      FileUtils.touch 'main.cpp'
    end

    after do
      FileUtils.remove 'main.cpp'
      Dir.chdir '..'
      Dir.rmdir 'working'
      Dir.chdir '..'
      Dir.rmdir '002'
    end

    describe '001: dummy driver available only test-mode' do

      it "001: git-contest-submit --help" do
        ret = `#{bin_path("git-contest-submit")} --help`
        ret.include?('test_dummy').should === true
        ret.include?('test_11111').should === true
        ret.include?('test_22222').should === true
        ret.include?('test_33333').should === true
      end

      it "002: no dummy" do
        ENV['TEST_MODE'] = 'FALSE'
        ret = `#{bin_path("git-contest-submit")} --help`
        ret.include?('test_dummy').should === false
        ret.include?('test_11111').should === true
        ret.include?('test_22222').should === true
        ret.include?('test_33333').should === true
      end

    end

    it "002: git-contest-submit test_dummy" do
      ret = `#{bin_path("git-contest-submit")} test_dummy 2>&1`
      ret.include?('Error').should === true
    end

    it "003: git-contest-submit test_dummy -c 100" do
      ret = `#{bin_path("git-contest-submit")} test_dummy -c 100 2>&1`
      ret.include?('Error').should === true
    end

    it "004: git-contest-submit test_dummy -c 100 -p A" do
      ret = `#{bin_path("git-contest-submit")} test_dummy -c 100 -p A 2>&1`
      ret.include?("99999").should === true
      ret.include?("Accepted").should === true
    end

  end

  describe '003: after init git repo' do

    before do
      ENV['GIT_CONTEST_CONFIG'] = get_path('/mock/t004/config.yml')
      Dir.mkdir '003'
      Dir.chdir '003'
      Dir.mkdir 'working'
      Dir.chdir 'working'
      FileUtils.touch 'main.cpp'
    end

    after do
      FileUtils.remove 'main.cpp'
      Dir.chdir '..'
      Dir.rmdir 'working'
      Dir.chdir '..'
      Dir.rmdir '003'
    end

    before do
      `#{bin_path("git-contest")} init --defaults`
    end

    after do
      FileUtils.remove_dir '.git', :force => true
    end

    it '001: submit' do
      ret_submit = `#{bin_path("git-contest-submit")} test_dummy -c 100 -p A 2>&1`
      ret_submit.include?("99999").should === true
      ret_submit.include?("Accepted").should === true
      ret_git = `git log --oneline --decorate --graph`
      ret_git.include?("Dummy Driver 99999: Accepted").should === true
    end

  end
 
end

