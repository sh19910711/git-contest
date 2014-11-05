require "spec_helper"

describe "T004: git-contest-submit command" do
  before do
    ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/config.yml"
    File.open "#{@temp_dir}/config.yml", 'w' do |file|
      file.write <<EOF
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
  test_11111:
    driver:   codeforces
    user:     dummy
    password: dummy
  test_22222:
    driver:   aizu_online_judge
    user:     dummy
    password: dummy
  test_33333:
    driver:   uva_online_judge
    user:     dummy
    password: dummy
EOF
    end
  end

  context "A001: --version" do
    it "git-contest-submit --version" do
      ret = `#{bin_path("git-contest-submit")} --version`
      expect(ret).to match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end

    it "git-contest submit --version" do
      ret = `#{bin_path("git-contest submit")} --version`
      expect(ret).to match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end

    it "git contest submit --version" do
      ret = `git contest submit --version`
      expect(ret).to match /git-contest [0-9]+\.[0-9]+\.[0-9]+/
    end
  end

  context "A002: --help" do
    before do
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    context "B001: dummy driver available only test-mode" do
      it "git-contest-submit --help" do
        ret = `#{bin_path('git-contest-submit')} --help`
        expect(ret).to include 'test_dummy'
        expect(ret).to include 'test_11111'
        expect(ret).to include 'test_22222'
        expect(ret).to include 'test_33333'
      end
    end
  end

  context "A003: after init git repo" do
    before do
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    before do
      `#{bin_path("git-contest")} init --defaults`
    end

    it "git-contest-submit test_dummy -c 100 -p A" do
      ret_submit = `#{bin_path("git-contest-submit")} test_dummy -c 100 -p A 2>&1`
      expect(ret_submit).to include '99999'
      expect(ret_submit).to include 'Accepted'
      ret_git = `git log --oneline --decorate --graph`
      expect(ret_git).to include "Dummy 100A: Accepted"
    end
  end

  context "A004: with commit message" do
    before do
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    before do
      bin_exec "init --defaults"
    end

    it "git contest submit test_dummy -c 100 -p A -m '...'" do
      bin_exec "submit test_dummy -c 100 -p A -m 'this is commit message'"
      ret = Git.do "log --oneline"
      expect(ret).to include "this is commit message"
    end
  end

  context 'A005: normal submit' do
    before do
      Dir.mkdir 'working'
      Dir.chdir 'working'
      File.open 'main.cpp', 'w' do |file|
        file.write 'ac-code'
      end
    end

    it "git-contest-submit test_dummy" do
      ret = `#{bin_path('git-contest-submit')} test_dummy 2>&1`
      expect(ret).to include 'Error'
    end

    it "git-contest-submit test_dummy -c 100" do
      ret = `#{bin_path('git-contest-submit')} test_dummy -c 100 2>&1`
      expect(ret).to include 'Error'
    end

    it "git-contest-submit test_dummy -c 100 -p A" do
      ret = `#{bin_path('git-contest-submit')} test_dummy -c 100 -p A 2>&1`
      expect(ret).to include '99999'
      expect(ret).to include 'Accepted'
    end
  end

  context 'A006: --source' do
    before do
      Dir.mkdir 'working'
      Dir.chdir 'working'
    end

    context "B001: submit single file" do
      before do
        File.open 'ac.cpp', 'w' do |file|
          file.write 'ac-code'
        end
        File.open 'wa.cpp', 'w' do |file|
          file.write 'wa-code'
        end
      end

      it "git contest submit test_dummy -c 100 -p A --source ac.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source ac.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A -s ac.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s ac.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A --source wa.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source wa.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A -s wa.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s wa.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Wrong Answer'
      end
    end

    context "B002: submit multiple files" do
      before do
        File.open '1.cpp', 'w' do |file|
          file.write 'wa-code'
        end
        File.open '2.cpp', 'w' do |file|
          file.write 'ac-code'
        end
      end

      it "git contest submit test_dummy -c 100 -p A --source 1.cpp,2.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source 1.cpp,2.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A --source 2.cpp,1.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A --source 2.cpp,1.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A -s 1.cpp,2.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 1.cpp,2.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A -s 2.cpp,1.cpp" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 2.cpp,1.cpp"
        expect(ret).to include '99999'
        expect(ret).to include 'Accepted'
      end

      it "git contest submit test_dummy -c 100 -p A -s 1.*,2.*" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 1.*,2.*"
        expect(ret).to include '99999'
        expect(ret).to include 'Wrong Answer'
      end

      it "git contest submit test_dummy -c 100 -p A -s 2.*,1.*" do
        ret = bin_exec "submit test_dummy -c 100 -p A -s 2.*,1.*"
        expect(ret).to include '99999'
        expect(ret).to include 'Accepted'
      end
    end
  end
end

