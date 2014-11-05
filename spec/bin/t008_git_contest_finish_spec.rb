require "spec_helper"

# Do not forget --no-edit option

describe "T008: git-contest-finish" do
  context "A001: --keep" do
    it "001: init -> start -> empty-commits -> finish" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      Git.do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit"
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1).not_to include "branch1"
      expect(ret_log1).to include "this is commit"
    end

    it "002: init -> start -> empty-commits -> finish --keep" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      Git.do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit --keep"
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1).to include "branch1"
      expect(ret_log1).to include "this is commit"
    end

    it "003: init -> start -> empty-commits -> finish -k" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      Git.do "commit --allow-empty -m 'this is commit'"
      bin_exec "finish --no-edit -k"
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1).to include "branch1"
      expect(ret_log1).to include "this is commit"
    end

  end

  context "A002: --rebase" do
    it "001: init -> start -> empty-commits -> finish --rebase" do
      # create branches: branch1(normal) -> branch2(rebase) -> branch3(normal)
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x|
        name = "test-1.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m 'Add #{name}'"
      }
      bin_exec "start branch2"
      10.times {|x|
        name = "test-2.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m 'Add #{name}'"
      }
      bin_exec "start branch3"
      10.times {|x|
        name = "test-3.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m 'Add #{name}'"
      }
      # finish branches
      ret_branch_1 = Git.do "branch"
      bin_exec "finish branch1 --no-edit"
      bin_exec "finish branch2 --no-edit --rebase"
      bin_exec "finish branch3 --no-edit"
      ret_branch_2 = Git.do "branch"
      ret_log = Git.do "log --oneline"
      expect(ret_branch_1).to include "branch1"
      expect(ret_branch_1).to include "branch2"
      expect(ret_branch_1).to include "branch3"
      expect(ret_branch_2).not_to include "branch1"
      expect(ret_branch_2).not_to include "branch2"
      expect(ret_branch_2).not_to include "branch3"
      expect(!!ret_log.match(/test-2.*test-3.*test-1/m)).to be_truthy
    end

  end

  context "A003: --force-delete" do
    # TODO: recheck
    it "001: init -> start -> trigger merge error -> finish --force-delete" do
      # make conflict
      bin_exec "init --defaults"
      FileUtils.touch "test.txt"
      Git.do "add test.txt"
      Git.do "commit -m 'Add test.txt'"
      bin_exec "start branch1"
      bin_exec "start branch2"
      Git.do "checkout contest/branch1"
      File.open "test.txt", "w" do |file|
        file.write "test1"
      end
      # Git.do "add test.txt"
      # Git.do "commit -m 'Edit test.txt @ branch1'"
      Git.do "checkout contest/branch2"
      File.open "test.txt", "w" do |file|
        file.write "test2"
      end
      Git.do "add test.txt"
      Git.do "commit -m 'Edit test.txt @ branch2'"
      # finish
      bin_exec "finish branch1 --no-edit"
      bin_exec "finish branch2 --force-delete --no-edit"
      ret_branch = Git.do "branch"
      expect(ret_branch).not_to include "contest/branch1"
      expect(ret_branch).not_to include "contest/branch2"
    end
  end

  context "A004: --squash" do
    it "001: init -> start -> empty-commits -> finish --squash" do
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x|
        filename = "test#{x}.txt"
        FileUtils.touch filename
        Git.do "add #{filename}"
        Git.do "commit -m 'this is commit #{x}'"
      }
      bin_exec "finish --no-edit --squash branch1"
      ret_log1 = Git.do "log --oneline"
      ret_branch1 = Git.do "branch"
      expect(ret_branch1).not_to include "branch1"
      expect(ret_log1).to include "this is commit"
      expect(ret_log1).to include "Squashed commit"
    end
  end

  context "A005: --fetch" do
    before do
      Dir.mkdir "src"
      Dir.chdir "src"
      bin_exec "init --defaults"
      bin_exec "start branch1"
      10.times {|x| Git.do "commit --allow-empty -m 'this is commit #{x}'" }
      Dir.chdir ".."
      Git.do "clone src dest"
      Dir.chdir "dest"
    end

    it "001: init -> start -> clone -> checkout@dest -> empty-commits@dest -> finish@dest" do
      Git.do "checkout -b master origin/master"
      bin_exec "init --defaults"
      bin_exec "start --fetch branch1"
      bin_exec "finish --fetch branch1 --no-edit"
      ret_branch2 = Git.do "branch"
      Dir.chdir ".."
      Dir.chdir "src"
      ret_branch1 = Git.do "branch"
      Git.do "checkout master"
      expect(ret_branch1).to include 'branch1'
      expect(ret_branch2).not_to include 'branch1'
    end
  end
end

