require "spec_helper"

describe "T007: git-contest-start" do

  def call_main(args)
    cli = CommandLine::MainCommand.new(args)
    cli.init
    cli
  end

  context "A001: specify based branch" do
    before do
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
    end

    it "001" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m \"this is commit\""
      Git.do "checkout master"
      expect { call_main(["start", "test1"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "log --oneline"
      expect(ret1).not_to include "this is commit"
      expect { call_main(["start", "test2", "base1"]).run }.to output(/.*/).to_stdout
      ret2 = Git.do "log --oneline"
      expect(ret2).to include "this is commit"
    end

    it "002" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m \"this is commit\""
      Git.do "checkout master"
      expect { call_main(["start", "test1", "base1"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "log --oneline"
      expect(ret1).to include "this is commit"
      expect { call_main(["start", "test2"]).run }.to output(/.*/).to_stdout
      ret2 = Git.do "log --oneline"
      expect(ret2).not_to include "this is commit"
    end

    it "003" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m \"this is commit\""
      expect { call_main(["start", "test1", "base1"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "log --oneline"
      expect(ret1).to include "this is commit"
      expect { call_main(["start", "test2"]).run }.to output(/.*/).to_stdout
      ret2 = Git.do "log --oneline"
      expect(ret2).not_to include "this is commit"
    end

    it "004" do
      Git.do "checkout -b base1"
      Git.do "commit --allow-empty -m \"this is commit\""
      expect { call_main(["start", "test1"]).run }.to output(/.*/).to_stdout
      ret1 = Git.do "log --oneline"
      expect(ret1).not_to include "this is commit"
      expect { call_main(["start", "test2", "base1"]).run }.to output(/.*/).to_stdout
      ret2 = Git.do "log --oneline"
      expect(ret2).to include "this is commit"
    end
  end

  context "A002: --fetch" do
    it "001" do
      Dir.mkdir "test1"
      Dir.chdir "test1"
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      expect { call_main(["start", "branch1"]).run }.to output(/.*/).to_stdout
      Dir.chdir ".."
      Git.do "clone -b master test1 test2"
      Dir.chdir "test1"
      3.times {|x| Git.do "commit --allow-empty -m \"this is commit\"" }
      ret1 = Git.do "log --oneline"
      expect(ret1).to include "this is commit"

      Dir.chdir ".."
      Dir.chdir "test2"
      # init
      expect { call_main(["init", "--defaults"]).run }.to output(/.*/).to_stdout
      # fetch
      ret2 = Git.do "log --oneline origin/master"
      expect(ret2).not_to include "this is commit"

      # TODO: support: start branch1 --fetch
      expect { call_main(["start", "--fetch", "branch1"]).run }.to output(/.*/).to_stdout

      ret3 = Git.do "log --oneline"
      expect(ret3).to_not include "this is commit"

      Git.do "pull origin master"
      expect { call_main(["start", "--fetch", "branch2"]).run }.to output(/Summary of actions/).to_stdout
    end
  end
end

