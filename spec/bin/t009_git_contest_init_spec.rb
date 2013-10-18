require "spec_helper"

# Don't forget --defaults option

describe "T009: git-contest-init" do

  describe "001: --force" do
    it "001: init -> init" do
      abort "to check: display already initalized error"
    end

    it "002: init -> init -f -> init --force" do
      abort "to check: does not display already initalized error"
    end

    it "003: init -f -> init -f -> init --force" do
      abort "to check: does not display already initalized error"
    end
  end

end

