require "spec_helper"

describe "T005: branching" do
  context "A001" do
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

    context 'B001' do 
      it '001: init -> start -> submit -> submit -> finish' do
        Dir.mkdir 'test1'
        Dir.chdir 'test1'

        # Init
        bin_exec "init --defaults"
        expect(Git.current_branch).to eq 'master'
        ret = Git.do "log --oneline"
        expect(ret).to include 'Initial commit'

        # Start
        bin_exec "start contest1"
        expect(Git.current_branch).to eq 'contest/contest1'

        # Edit.1
        File.open 'main.c', 'w' do |file|
          file.write 'wa-code'
        end

        # Submit.1
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = Git.do "log --oneline"
        expect(ret).to include 'Dummy 1000A: Wrong Answer'

        ret = Git.do "ls-files"
        expect(ret).to include 'main.c'

        # Edit.2 fixed
        File.open 'main.c', 'w' do |file|
          file.write 'ac-code'
        end

        # Submit.2
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = Git.do "log --oneline"
        expect(ret).to include 'Dummy 1000A: Accepted'

        ret = Git.do "ls-files"
        expect(ret).to include 'main.c'

        # Finish
        bin_exec "finish --no-edit"
        expect(Git.current_branch).to eq 'master'

        ret = Git.do "log --oneline"
        expect(ret).to include 'Dummy 1000A: Wrong Answer'
        expect(ret).to include 'Dummy 1000A: Accepted'
      end
    end
  end
end

