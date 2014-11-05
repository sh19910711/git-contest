require "spec_helper"

describe "T006: Config Test" do 
  context "A001: submit_rules" do
    context "B001: commit_message" do
      before do
        File.open "main.d", "w" do |file|
          file.write "ac-code"
        end
        bin_exec "init --defaults"
      end

      it "001: ${site} ${problem-id}: ${status}" do
        set_git_contest_config <<EOF
submit_rules:
  message:    "${site} ${problem-id}: ${status}"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Dummy 100A: Accepted'
      end

      it "002: ${site}-${problem-id}-${status}" do
        set_git_contest_config <<EOF
submit_rules:
  message:    "${site}-${problem-id}-${status}"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Dummy-100A-Accepted'
      end

      it "003: ${status}-${site}" do
        set_git_contest_config <<EOF
submit_rules:
  message:    "${status}-${site}"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Accepted-Dummy'
      end

    end

    context "B002: source" do
      before do
        File.open "ac.cpp", "w" do |file|
          file.write "ac-code"
        end
        File.open "wa.d", "w" do |file|
          file.write "wa-code"
        end
        File.open "tle.go", "w" do |file|
          file.write "tle-code"
        end
        bin_exec "init --defaults"
      end

      it "001: ac.*" do
        set_git_contest_config <<EOF
submit_rules:
  source: "ac.*"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"

        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Dummy 100A: Accepted'

        ret_ls1 = Git.do "ls-files"
        expect(ret_ls1).to include 'ac.cpp'
      end

      it "002: wa.*" do
        set_git_contest_config <<EOF
submit_rules:
  source: "wa.*"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"

        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Dummy 100A: Wrong Answer'

        ret_ls1 = Git.do "ls-files"
        expect(ret_ls1).to include 'wa.d'
      end

      it "003: tle.*" do
        set_git_contest_config <<EOF
submit_rules:
  source: "tle.*"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "log --oneline"
        expect(ret1).to include 'Dummy 100A: Time Limit Exceeded'

        ret_ls1 = Git.do "ls-files"
        expect(ret_ls1).to include 'tle.go'
      end
    end

    context "B003: add" do
      before do
        File.open "test1.cpp", "w" do |file|
          file.write "ac-code"
        end
        File.open "input1.txt", "w" do |file|
          file.write "test"
        end
        File.open "test2.c", "w" do |file|
          file.write "wa-code"
        end
        File.open "input2.txt", "w" do |file|
          file.write "test2"
        end
        bin_exec "init --defaults"
      end

      it "001: test*.cpp input1.txt" do
        set_git_contest_config <<EOF
submit_rules:
  source: "test*.cpp"
  add:    "test*.cpp input1.txt"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "ls-files"
        expect(ret1).to include "test1.cpp"
        expect(ret1).to include "input1.txt"
        expect(ret1).not_to include "test2.c"
        expect(ret1).not_to include "input2.txt"
      end

      it "002: input2.txt test*.c" do
        set_git_contest_config <<EOF
submit_rules:
  source: "test*.c"
  add:    "input2.txt test*.c"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "ls-files"
        expect(ret1).not_to include "test1.cpp"
        expect(ret1).not_to include "input1.txt"
        expect(ret1).to include "test2.c"
        expect(ret1).to include "input2.txt"
      end

      it "003: input1.txt test1.cpp test2.c input2.txt" do
        set_git_contest_config <<EOF
submit_rules:
  source: "test*.cpp"
  add:    "input1.txt test1.cpp test2.c input2.txt"
sites:
  test_dummy:
    driver:   dummy
    user:     dummy
    password: dummy
EOF
        bin_exec "submit test_dummy -c 100 -p A"
        ret1 = Git.do "ls-files"
        expect(ret1).to include "test1.cpp"
        expect(ret1).to include "input1.txt"
        expect(ret1).to include "test2.c"
        expect(ret1).to include "input2.txt"
      end
    end
  end

  context "A002: file" do
    context "B001: ext" do
      before do
        File.open "test1.dummy", "w" do |f|
          f.write "wa-code"
        end
        File.open "test2.cpp", "w" do |f|
          f.write "wa-code"
        end
      end

      it "dummy -> c++11" do
        set_git_contest_config <<EOF
file:
  ext:
    dummy: c++11
sites:
  test_dummy:
    driver: dummy
    user: dummy
    password: dummy
EOF
        
        ret1 = bin_exec "submit test_dummy -c 100 -p A -s test1.dummy"
        expect(ret1).not_to include "unknown language"
      end

      it "cpp -> dummy" do
        set_git_contest_config <<EOF
file:
  ext:
    cpp: dummy
sites:
  test_dummy:
    driver: dummy
    user: dummy
    password: dummy
EOF
        
        ret1 = bin_exec "submit test_dummy -c 100 -p A -s test2.cpp"
        expect(ret1).to include "unknown language"
      end

      it "cpp -> cpp11" do
        set_git_contest_config <<EOF
file:
  ext:
    cpp: dummy
sites:
  test_dummy:
    driver: dummy
    user: dummy
    password: dummy
EOF
        
        ret1 = bin_exec "submit test_dummy -c 100 -p A -s test2.cpp"
        expect(ret1).to include "unknown language"
      end
    end
  end

end

