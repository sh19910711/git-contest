require "spec_helper"

describe "T005: branching" do

  def call_main(args)
    cli = CommandLine::MainCommand.new(args)
    cli.init
    cli
  end

  context "create config file" do

    before do
      ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/home/config.yml"
      File.open ENV['GIT_CONTEST_CONFIG'], "w" do |file|
        file.write <<EOF
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
      end
    end

    context "$ git contest init", :current => true do

      before { expect {call_main(["init", "--defaults"]).run}.to output("").to_stdout }
      it { expect(Git.current_branch).to eq "master" }

      context "$ git contest start contest1" do

        before { expect {call_main(["start", "contest1"]).run}.to output(/contest1/).to_stdout }
        it { expect(Git.current_branch).to eq "contest/contest1" }

        context "edit main.c as wrong" do

          before do
            File.open 'main.c', 'w' do |file|
              file.write 'wa-code'
            end
          end

          context "$ git contest submit" do

            before { expect {call_main(["submit", "test_dummy", "-c", "1000", "-p", "A"]).run}.to output(/Wrong Answer/).to_stdout }

            context "fix main.c" do

              before do
                File.open 'main.c', 'w' do |file|
                  file.write 'ac-code'
                end
              end

              context "$ git contest submit (resubmit)" do

                before { expect {call_main(["submit", "test_dummy", "-c", "1000", "-p", "A"]).run}.to output(/Accepted/).to_stdout }

                context "$ git contest finish" do

                  before { expect {call_main(["finish", "--no-edit"]).run}.to output(/contest1/).to_stdout }
                  it { expect(Git.current_branch).to eq "master" }

                  context "$ git log" do

                    subject { Git.do "log --oneline" }
                    it { should include "Dummy 1000A: Wrong Answer" }
                    it { should include "Dummy 1000A: Accepted" }

                  end # git log

                end # git contest finish

              end # git contest submit (resubmit)

            end # fix main.c

          end # git contest sbumit

        end # edit main.c

      end # git contest start contest1

    end # git contest init

  end # create config file

end # brancing

