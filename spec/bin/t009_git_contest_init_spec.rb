require "spec_helper"

# Don't forget --defaults option

describe "T009: git-contest-init" do

  def call_main(args)
    cli = CommandLine::MainCommand.new(args)
    cli.init
    cli
  end

  describe "--force option" do

    context "$ git contest init" do

      before do
        expect { call_main(["init", "--defaults"]).run }.to output("").to_stdout
      end

      context "config --get" do
        it { expect(Git.do "config --get git.contest.branch.master").to eq "master" }

        context "$ git contest init" do
          subject { lambda { call_main(["init", "--defaults"]).run } }
          it { should output(/Already initialized/).to_stdout.and raise_error SystemExit }
          it { should output(/init -f/).to_stdout.and raise_error SystemExit }
        end

        context "$ git contest init -f" do
          before do
            expect { call_main(["init", "--defaults", "-f"]).run }.to output("").to_stdout
          end

          context "$ git contest init --force" do
            before do
              expect { call_main(["init", "--defaults", "--force"]).run }.to output("").to_stdout
            end
            context "config --get" do
              it { expect(Git.do "config --get git.contest.branch.master").to eq "master" }
            end
          end
        end

      end

    end # git contest init

    context "$ git contest init -f" do

      before do
        expect { call_main(["init", "--defaults", "-f"]).run }.to output("").to_stdout
      end

      context "config --get" do
        it { expect(Git.do "config --get git.contest.branch.master").to eq "master" }

        context "$ git contest init" do
          subject { lambda { call_main(["init", "--defaults"]).run } }
          it { should output(/Already initialized/).to_stdout.and raise_error SystemExit }
          it { should output(/init -f/).to_stdout.and raise_error SystemExit }
        end

        context "$ git contest init -f" do
          before do
            expect { call_main(["init", "--defaults", "-f"]).run }.to output("").to_stdout
          end

          context "$ git contest init --force" do
            before do
              expect { call_main(["init", "--defaults", "--force"]).run }.to output("").to_stdout
            end
            context "config --get" do
              it { expect(Git.do "config --get git.contest.branch.master").to eq "master" }
            end
          end
        end

      end

    end # git contest init -f

  end # --force option
end # git-contest-init

