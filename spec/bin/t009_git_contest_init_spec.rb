require "spec_helper"

# Don't forget --defaults option

describe "T009: git-contest-init" do
  context "A001: --force" do
    it "001: init -> init" do
      ret1 = bin_exec "init --defaults"
      ret_config1 = Git.do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults"
      expect(ret_config1).to eq "master"
      expect(ret1).not_to include "Error: unknown argument"
      expect(ret2).not_to include "Error: unknown argument"
      expect(ret1).not_to include "Already initialized for git-contest."
      expect(ret1).not_to include "use: git contest init -f"
      expect(ret2).to include "Already initialized for git-contest."
      expect(ret2).to include "use: git contest init -f"
    end

    it "002: init -> init -f -> init --force" do
      ret1 = bin_exec "init --defaults"
      ret_config1 = Git.do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults -f"
      ret3 = bin_exec "init --defaults --force"
      expect(ret_config1).to eq "master"
      expect(ret1).not_to include "Error: unknown argument"
      expect(ret2).not_to include "Error: unknown argument"
      expect(ret3).not_to include "Error: unknown argument"
      expect(ret1).not_to include "Already initialized for git-contest."
      expect(ret1).not_to include "use: git contest init -f"
      expect(ret2).not_to include "Already initialized for git-contest."
      expect(ret2).not_to include "use: git contest init -f"
      expect(ret3).not_to include "Already initialized for git-contest."
      expect(ret3).not_to include "use: git contest init -f"
    end

    it "003: init -f -> init -f -> init --force" do
      ret1 = bin_exec "init --defaults -f"
      ret_config1 = Git.do("config --get git.contest.branch.master")
      ret2 = bin_exec "init --defaults -f"
      ret3 = bin_exec "init --defaults --force"
      expect(ret_config1).to eq "master"
      expect(ret1).not_to include "Error: unknown argument"
      expect(ret2).not_to include "Error: unknown argument"
      expect(ret3).not_to include "Error: unknown argument"
      expect(ret1).not_to include "Already initialized for git-contest."
      expect(ret1).not_to include "use: git contest init -f"
      expect(ret2).not_to include "Already initialized for git-contest."
      expect(ret2).not_to include "use: git contest init -f"
      expect(ret3).not_to include "Already initialized for git-contest."
      expect(ret3).not_to include "use: git contest init -f"
    end
  end
end

