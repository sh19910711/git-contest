require "spec_helper"

describe "T007: git-contest-start" do
  context "A001: specify based branch" do
    before do
      bin_exec "init --defaults"
    end

    it "001" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m 'this is commit'"
      Git.do "checkout master"
      bin_exec "start test1"
      ret1 = Git.do "log --oneline"
      expect(ret1).not_to include "this is commit"
      bin_exec "start test2 base1"
      ret2 = Git.do "log --oneline"
      expect(ret2).to include "this is commit"
    end

    it "002" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m 'this is commit'"
      Git.do "checkout master"
      bin_exec "start test1 base1"
      ret1 = Git.do "log --oneline"
      expect(ret1).to include "this is commit"
      bin_exec "start test2"
      ret2 = Git.do "log --oneline"
      expect(ret2).not_to include "this is commit"
    end

    it "003" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m 'this is commit'"
      bin_exec "start test1 base1"
      ret1 = Git.do "log --oneline"
      expect(ret1).to include "this is commit"
      bin_exec "start test2"
      ret2 = Git.do "log --oneline"
      expect(ret2).not_to include "this is commit"
    end

    it "004" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m 'this is commit'"
      bin_exec "start test1"
      ret1 = Git.do "log --oneline"
      expect(ret1).not_to include "this is commit"
      bin_exec "start test2 base1"
      ret2 = Git.do "log --oneline"
      expect(ret2).to include "this is commit"
    end
  end

  context "A002: --fetch" do
    it "001" do
      Dir.mkdir "test1"
      Dir.chdir "test1"
      bin_exec "init --defaults"
      Dir.chdir ".."
      Git.do "clone test1 test2"
      Dir.chdir "test1"
      10.times {|x| Git.do "commit --allow-empty -m 'this is commit'" }
      ret1 = Git.do "log --oneline master"
      expect(ret1).to include "this is commit"

      Dir.chdir ".."
      Dir.chdir "test2"
      # init
      bin_exec "init --defaults"
      # fetch
      ret2 = Git.do "log --oneline origin/master"
      expect(ret2).not_to include "this is commit"

      ret_start1 = bin_exec "start branch1 --fetch"
      expect(ret_start1).not_to include "Summary of actions:"

      ret3 = Git.do "log --oneline origin/master"
      expect(ret3).to include "this is commit"

      Git.do "pull origin master"
      ret_start2 = bin_exec "start branch2 --fetch"
      expect(ret_start2).to include "Summary of actions:"
    end
  end
end

