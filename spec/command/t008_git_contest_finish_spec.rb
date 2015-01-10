require "spec_helper"

# Do not forget --no-edit option

describe "T008: git-contest-finish" do

  def call_main(args)
    cli = CommandLine::MainCommand.new(args)
    cli.init
    cli
  end

  context "A001: --keep" do
    it "001: init -> start -> empty-commits -> finish" do
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      Git.do "commit --allow-empty -m \"this is commit\""
      expect { call_main(["finish", "--no-edit"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1.split(/\s+/)).not_to include /branch1/
      expect(ret_log1).to match /this is commit/
    end

    it "002: init -> start -> empty-commits -> finish --keep" do
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      Git.do "commit --allow-empty -m \"this is commit\""
      expect { call_main(["finish", "--no-edit", "--keep"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1.split(/\s+/)).to include /branch1/
      expect(ret_log1).to match /this is commit/
    end

    it "003: init -> start -> empty-commits -> finish -k" do
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      Git.do "commit --allow-empty -m \"this is commit\""
      expect { call_main(["finish", "--no-edit", "-k"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "branch"
      ret_log1 = Git.do "log --oneline master"
      expect(ret1.split(/\s+/)).to include /branch1/
      expect(ret_log1).to match /this is commit/
    end

  end

  context "A002: --rebase" do
    it "001: init -> start -> empty-commits -> finish --rebase" do
      # create branches: branch1(normal) -> branch2(rebase) -> branch3(normal)
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      3.times {|x|
        name = "test-1.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m \"Add #{name}\""
      }
      expect { call_main(["start", "branch2"]).run }.to output(/.*/).to_stdout
      3.times {|x|
        name = "test-2.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m \"Add #{name}\""
      }
      expect { call_main(["start", "branch3"]).run }.to output(/.*/).to_stdout
      3.times {|x|
        name = "test-3.#{x}"
        FileUtils.touch name
        Git.do "add #{name}"
        Git.do "commit -m \"Add #{name}\""
      }
      # finish branches
      ret_branch_1 = Git.do "branch"
      expect { call_main(["finish", "--no-edit", "branch1"]).run }.to output(/.*/).to_stdout
      expect { call_main(["finish", "--no-edit", "--rebase", "branch2"]).run }.to output(/.*/).to_stdout
      expect { call_main(["finish", "--no-edit", "branch3"]).run }.to output(/.*/).to_stdout
      ret_branch_2 = Git.do "branch"
      ret_log = Git.do "log --oneline"
      expect(ret_branch_1.split(/\s+/)).to include /branch1/
      expect(ret_branch_1.split(/\s+/)).to include /branch2/
      expect(ret_branch_1.split(/\s+/)).to include /branch3/
      expect(ret_branch_2.split(/\s+/)).not_to include /branch1/
      expect(ret_branch_2.split(/\s+/)).not_to include /branch2/
      expect(ret_branch_2.split(/\s+/)).not_to include /branch3/
      expect(ret_log).to match /test-2.*test-3.*test-1/m
    end

  end

  context "A003: --force-delete" do
    # TODO: recheck
    it "001: init -> start -> trigger merge error -> finish --force-delete" do
      # make conflict
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      FileUtils.touch "test.txt"
      Git.do "add test.txt"
      Git.do "commit -m \"Add test.txt\""
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch2"]).run }.to output(/.*/).to_stdout
      Git.do "checkout contest/branch1"
      File.open "test.txt", "w" do |file|
        file.write "test1"
      end
      # Git.do "add test.txt"
      # Git.do "commit -m \"Edit test.txt @ branch1\""
      Git.do "checkout contest/branch2"
      File.open "test.txt", "w" do |file|
        file.write "test2"
      end
      Git.do "add test.txt"
      Git.do "commit -m \"Edit test.txt @ branch2\""
      # finish
      expect { call_main(["finish", "--no-edit", "branch1"]).run }.to output(/.*/).to_stdout
      expect { call_main(["finish", "--no-edit", "--force-delete", "branch2"]).run }.to output(/.*/).to_stdout
      ret_branch = Git.do "branch"
      expect(ret_branch.split(/\s+/)).not_to include /contest\/branch1/
      expect(ret_branch.split(/\s+/)).not_to include /contest\/branch2/
    end
  end

  context "A004: --squash" do
    it "001: init -> start -> empty-commits -> finish --squash" do
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      3.times do |x|
        filename = "test#{x}.txt"
        FileUtils.touch filename
        Git.do "add #{filename}"
        Git.do "commit -m \"this is commit #{x}\""
      end
      expect { call_main(["finish", "--no-edit", "--squash", "branch1"]).run }.to output(/.*/).to_stdout
      ret_log1 = Git.do "log --oneline"
      ret_branch1 = Git.do "branch"
      expect(ret_branch1.split(/\s+/)).not_to include /branch1/
      expect(ret_log1).to match /this is commit/
      expect(ret_log1).to match /Squashed commit/
    end
  end

  context "A005: --fetch" do
    before do
      Dir.mkdir "src"
      Dir.chdir "src"
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      3.times {|x| Git.do "commit --allow-empty -m \"this is commit #{x}\"" }
      Dir.chdir ".."
      Git.do "clone --single-branch -b master src dest"
      Dir.chdir "dest"
    end

    it "001: init -> start -> clone -> checkout@dest -> empty-commits@dest -> finish@dest" do
      Git.do "checkout -b master origin/master"
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "--fetch", "branch1"]).run }.to output(/.*/).to_stdout
      expect { call_main(["finish", "--no-edit", "--fetch", "branch1"]).run }.to output(/.*/).to_stdout
      ret_branch2 = Git.do "branch"
      Dir.chdir ".."
      Dir.chdir "src"
      ret_branch1 = Git.do "branch"
      Git.do "checkout master"
      expect(ret_branch1.split(/\s+/)).to include /branch1/
      expect(ret_branch2.split(/\s+/)).to_not include /branch1/
    end
  end
end

