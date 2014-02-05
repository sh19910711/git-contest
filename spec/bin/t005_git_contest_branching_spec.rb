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

    describe '001' do 
      it '001: init -> start -> submit -> submit -> finish' do
        Dir.mkdir 'test1'
        Dir.chdir 'test1'

        # Init
        bin_exec "init --defaults"
        git_current_branch.should === 'master'
        ret = git_do "log --oneline"
        ret.include?('Initial commit').should === true

        # Start
        bin_exec "start contest1"
        git_current_branch.should === 'contest/contest1'

        # Edit.1
        File.open 'main.c', 'w' do |file|
          file.write 'wa-code'
        end

        # Submit.1
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Wrong Answer').should === true
        ret = git_do "ls-files"
        ret.include?('main.c').should === true

        # Edit.2 fixed
        File.open 'main.c', 'w' do |file|
          file.write 'ac-code'
        end

        # Submit.2
        bin_exec "submit test_dummy -c 1000 -p A"
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Accepted').should === true
        ret = git_do "ls-files"
        ret.include?('main.c').should === true

        # Finish
        bin_exec "finish --no-edit"
        git_current_branch.should === 'master'
        ret = git_do "log --oneline"
        ret.include?('Dummy 1000A: Wrong Answer').should === true
        ret.include?('Dummy 1000A: Accepted').should === true
      end
    end
  end
end

