require "spec_helper"

# Do not forget --no-edit option

describe "T008: git-contest-finish" do

  before do
    init_env
    @test_dir = "#{ENV['GIT_CONTEST_TEMP_DIR']}/t008"
    Dir.mkdir @test_dir
    Dir.chdir @test_dir
  end

  after do
    Dir.chdir '..'
    Dir.rmdir @test_dir
  end

  describe "001: --keep" do

    before do
      Dir.mkdir "001"
      Dir.chdir "001"
      debug_on
    end

    after do
      FileUtils.remove_dir ".git", :force => true
      Dir.chdir ".."
      Dir.rmdir "001"
    end

    it "001: init -> start -> empty-commits -> finish" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit"
      ret1 = git_do "branch"
      ret1.include?("branch1").should === false
    end

    it "002: init -> start -> empty-commits -> finish --keep" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit --keep"
      ret1 = git_do "branch"
      ret1.include?("branch1").should === true
    end

    it "003: init -> start -> empty-commits -> finish -k" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      git_do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit -k"
      ret1 = git_do "branch"
      ret1.include?("branch1").should === true
    end

  end

  describe "002: --rebase" do

    it "001: init -> start -> empty-commits -> finish --rebase" do
      abort "to check: merge commit does not exist"
    end

  end

  describe "003: --force_delete" do

    it "001: init -> start -> trigger merge error -> finish --force_delete" do
      abort "to check: branch does not exist"
    end

  end

  describe "004: --squash" do 

    it "001: init -> start -> empty-commits -> finish --squash" do
      abort "to check: empty-commits does not exist"
      abort "to check: merge commit exists"
    end

  end

  describe "005: --fetch" do

    it "001: init -> start -> clone -> checkout@dest -> empty-commits@dest -> finish@dest" do
      abort "to check: empty-commits exists at src-repo"
    end

  end

end

