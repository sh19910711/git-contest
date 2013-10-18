require "spec_helper"

# Do not forget --no-edit option

describe "T008: git-contest-finish" do
  describe "001: --keep" do
    it "001: init -> start -> empty-commits -> finish" do
      abort "to check: does not exist"
    end
    it "002: init -> start -> empty-commits -> finish --keep" do
      abort "to check: exist"
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

