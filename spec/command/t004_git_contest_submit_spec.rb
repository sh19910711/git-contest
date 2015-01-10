require "spec_helper"

module CommandLine

  describe "T004: git-contest-submit command" do

    before do
      ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/config.yml"
      File.write "#{@temp_dir}/config.yml", [
        'sites:',
        '  test_dummy:',
        '    driver:   dummy',
        '    user:     dummy',
        '    password: dummy',
        '  test_11111:',
        '    driver:   codeforces',
        '    user:     dummy',
        '    password: dummy',
        '  test_22222:',
        '    driver:   aizu_online_judge',
        '    user:     dummy',
        '    password: dummy',
        '  test_33333:',
        '    driver:   uva_online_judge',
        '    user:     dummy',
        '    password: dummy'
      ].join($/)
    end

    def call_submit(args)
      cli = SubCommands::SubmitCommand.new(args)
      cli.init
      cli
    end

    def call_main(args)
      cli = MainCommand.new(args)
      cli.init
      cli
    end

    def call_init(args)
      cli = SubCommands::InitCommand.new(args)
      cli.init
      cli
    end

    context "A001: --version" do

      context "git-contest-submit --version" do
        it { expect { call_submit(["--version"])}.to output(/[0-9]+\.[0-9]+\.[0-9]+/).to_stdout.and raise_error SystemExit }
      end

      context "git-contest submit --version" do
        it { expect { call_main(["submit", "--version"]).run }.to output(/[0-9]+\.[0-9]+\.[0-9]+/).to_stdout.and raise_error SystemExit }
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
        context "git-contest-submit --help" do
          subject { lambda { call_submit(['--help']).run } }
          it { should output(/test_dummy/).to_stdout.and raise_error SystemExit }
          it { should output(/test_11111/).to_stdout.and raise_error SystemExit }
          it { should output(/test_22222/).to_stdout.and raise_error SystemExit }
          it { should output(/test_33333/).to_stdout.and raise_error SystemExit }
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
        call_init(['--defaults']).run
      end

      context "git-contest-submit test_dummy -c 100 -p A" do

        context "output" do
          subject { lambda { call_submit(['test_dummy', '-c', '100', '-p', 'A']).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
          it { should output(/@commit/).to_stdout }
        end

        context "submit" do
          before { expect { call_submit(['test_dummy', '-c', '100', '-p', 'A']).run }.to output(/@commit/).to_stdout }
          it do
            ret_git = `git log --oneline`
            expect(ret_git).to match /Dummy 100A: Accepted/
          end
        end
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

      before { expect { call_init(["--defaults"]).run }.to output("").to_stdout }

      context "git contest submit test_dummy -c 100 -p A -m '...'" do
        before { expect { call_submit(['test_dummy', '-c', '100', '-p', 'A', '-m', 'this is commit message']).run }.to output(/@commit/).to_stdout }
        it do
          ret = Git.do "log --oneline"
          expect(ret).to include "this is commit message"
        end
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

      context "git-contest-submit test_dummy" do
        subject { lambda { call_submit(["test_dummy"]).run } }
        it { should output(/Error/).to_stderr.and raise_error SystemExit }
      end

      context "git-contest-submit test_dummy -c 100" do
        subject { lambda { call_submit(["test_dummy", "-c", "100"]).run } }
        it { should output(/Error/).to_stderr.and raise_error SystemExit }
      end

      context "git-contest-submit test_dummy -c 100 -p A" do
        subject { lambda { call_submit(['test_dummy', '-c', '100', '-p', 'A']).run } }
        it { should output(/99999/).to_stdout }
        it { should output(/Accepted/).to_stdout }
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

        context "git contest submit test_dummy -c 100 -p A --source ac.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "--source", "ac.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s ac.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "ac.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A --source wa.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "--source", "wa.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Wrong Answer/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s wa.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "wa.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Wrong Answer/).to_stdout }
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

        context "git contest submit test_dummy -c 100 -p A --source 1.cpp,2.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "--source", "1.cpp,2.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Wrong Answer/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A --source 2.cpp,1.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "--source", "2.cpp,1.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s 1.cpp,2.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "1.cpp,2.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Wrong Answer/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s 2.cpp,1.cpp" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "2.cpp,1.cpp"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s 1.*,2.*" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "1.*,2.*"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Wrong Answer/).to_stdout }
        end

        context "git contest submit test_dummy -c 100 -p A -s 2.*,1.*" do
          subject { lambda { call_submit(["test_dummy", "-c", "100", "-p", "A", "-s", "2.*,1.*"]).run } }
          it { should output(/99999/).to_stdout }
          it { should output(/Accepted/).to_stdout }
        end
      end
    end
  end

end # CommandLine

