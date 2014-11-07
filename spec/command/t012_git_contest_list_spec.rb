require 'spec_helper'

describe "T012: git-contest-list" do

  def call_main(args)
    cli = CommandLine::MainCommand.new(args)
    cli.init
    cli
  end

  before do
    ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/config.yml"
    ENV['GIT_CONTEST_HOME'] = @temp_dir
  end

  context "git-contest-list sites" do
    before do
      # create config
      File.open "#{@temp_dir}/config.yml", 'w' do |file|
        file.write <<EOF
sites:
  test_site1:
    driver: test_driver1
    user: test_user1
    password: test_password1
  test_site2:
    driver: test_driver2
    user: test_user2
    password: test_password2
  test_site3:
    driver: test_driver3
    user: test_user3
    password: test_password3
EOF
      end
    end

    context "git-contest list sites" do
      subject { lambda { call_main(["list", "sites"]).run } }
      describe "site" do
        it { should output(/test_site1/).to_stdout }
        it { should output(/test_site2/).to_stdout }
        it { should output(/test_site3/).to_stdout }
      end 

      describe "user" do
        it { should output(/test_user1/).to_stdout }
        it { should output(/test_user2/).to_stdout }
        it { should output(/test_user3/).to_stdout }
      end

      describe "driver" do
        it { should output(/test_driver1/).to_stdout }
        it { should output(/test_driver2/).to_stdout }
        it { should output(/test_driver3/).to_stdout }
      end

      describe "password (hidden)" do
        it { should_not output(/test_password1/).to_stdout }
        it { should_not output(/test_password2/).to_stdout }
        it { should_not output(/test_password3/).to_stdout }
      end
    end

  end

  context "git-contest-list drivers" do
    before do
      # prepare drivers
      FileUtils.mkdir "#{@temp_dir}/plugins"
      File.open "#{@temp_dir}/plugins/test01_driver.rb", "w" do |f|
        f.write <<EOF
module Contest
  module Driver
    class Test01Driver < DriverBase
      def get_site_name
        "test01_site_name"
      end
      def get_desc
        "test01_desc"
      end
    end
  end
end
EOF
      end
      File.open "#{@temp_dir}/plugins/test02_driver.rb", "w" do |f|
        f.write <<EOF
module Contest
  module Driver
    class Test02Driver < DriverBase
      def get_site_name
        "test02_site_name"
      end
      def get_desc
        "test02_desc"
      end
    end
  end
end
EOF
      end
    end

    context "$ git contest list drivers" do

      subject { lambda { call_main(["list", "drivers"]).run } }

      context "class" do
        it { should output(/Test01Driver/).to_stdout }
        it { should output(/Test02Driver/).to_stdout }
      end

      context "desc" do
        it { should output(/test01_desc/).to_stdout }
        it { should output(/test02_desc/).to_stdout }
      end

    end

  end

end
