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
        ret1 = git_do "log --oneline"
        ret1.include?('Dummy 100A: Accepted').should === true
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
        ret1 = git_do "log --oneline"
        ret1.include?('Dummy-100A-Accepted').should === true
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
        ret1 = git_do "log --oneline"
        ret1.include?('Accepted-Dummy').should === true
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
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Accepted').should === true
        ret_ls1.include?('ac.cpp').should === true
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
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Wrong Answer').should === true
        ret_ls1.include?('wa.d').should === true
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
        ret1 = git_do "log --oneline"
        ret_ls1 = git_do "ls-files"
        ret1.include?('Dummy 100A: Time Limit Exceeded').should === true
        ret_ls1.include?('tle.go').should === true
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
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === true
        ret1.include?("input1.txt").should === true
        ret1.include?("test2.c").should    === false
        ret1.include?("input2.txt").should === false
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
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === false
        ret1.include?("input1.txt").should === false
        ret1.include?("test2.c").should    === true
        ret1.include?("input2.txt").should === true
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
        ret1 = git_do "ls-files"
        ret1.include?("test1.cpp").should  === true
        ret1.include?("input1.txt").should === true
        ret1.include?("test2.c").should    === true
        ret1.include?("input2.txt").should === true
      end
    end
  end
end

