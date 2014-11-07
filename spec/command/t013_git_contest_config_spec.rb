require 'spec_helper'
require 'yaml'

describe "T013: git-contest-config" do

  def call_main(args, new_stdin = STDIN)
    cli = CommandLine::MainCommand.new(args, new_stdin)
    cli.init
    cli
  end

  before do
    ENV['GIT_CONTEST_CONFIG'] = "#{@temp_dir}/config.yml"
  end

  context "git contest config set" do
    before(:each) do
      # create config file
      File.open "#{@temp_dir}/config.yml", 'w' do |file|
        file.write <<EOF
key1: value1
sites:
  test_site1:
    driver: test_driver1
    user: test_user1
    password: test_password1
EOF
      end
    end

    context "git contest config set key value1" do

      let(:fake_input) { ::StringIO.new("value2") }

      before { expect { call_main(["config", "set", "key1"], fake_input).run }.to output(/input value/).to_stdout }

      context "load config" do
        let(:conf) { YAML.load_file "#{@temp_dir}/config.yml" }

        it { expect(conf["key1"]).to eq "value2" }
      end
    end

    it "git contest config set sites.test_site1.driver test_driver2" do
      expect { call_main(["config", "set", "sites.test_site1.driver", "test_driver2"]).run }.to output(/.*/).to_stdout

      ret1 = YAML.load_file "#{@temp_dir}/config.yml"
      expect(ret1["sites"]["test_site1"]["driver"]).to eq "test_driver2"
    end
  end

  context "git contest config get" do
    before(:each) do
      # create config file
      File.open "#{@temp_dir}/config.yml", 'w' do |file|
        file.write <<EOF
key1: value1
sites:
  test_site1:
    driver: test_driver1
    user: test_user1
    password: test_password1
EOF
      end
    end

    it "git contest config get key1" do
      expect { call_main(["config", "get", "key1"]).run }.to output(/value1/).to_stdout
    end

    it "git contest config get sites.test_site1.user" do
      expect { call_main(["config", "get", "sites.test_site1.user"]).run }.to output(/test_user1/).to_stdout
    end

    context "config get sites.test_site1" do
      subject { lambda { call_main(["config", "get", "sites.test_site1"]).run } }
      it { should output(/driver/).to_stdout }
      it { should output(/user/).to_stdout }
      it { should output(/password/).to_stdout }
      it { should_not output(/test_driver1/).to_stdout }
      it { should_not output(/test_user1/).to_stdout }
      it { should_not output(/test_password1/).to_stdout }
    end

    it "raise error: not found" do
      expect { call_main(["config", "get", "foo.bar"]).run }.to output(/ERROR/).to_stderr.and raise_error SystemExit
    end
  end

  context "git contest config site add" do
    before(:each) do
      # create config
      File.open "#{@temp_dir}/config.yml", "w" do |file|
        file.write <<EOF
sites:
  test_site1:
    driver: test_driver1
    user: test_user1
    password: test_password1
EOF
      end
    end


    context "$ git contest config site add test_site2" do

      let(:fake_input) { ::StringIO.new("test_driver2\ntest_user2\ntest_password2") }
      before { expect { call_main(["config", "site", "add", "test_site2"], fake_input).run }.to output(/.*/).to_stdout }

      context "load config" do
        let(:conf) { YAML.load_file "#{@temp_dir}/config.yml" }
        it { expect(conf["sites"]["test_site1"]["driver"]).to eq "test_driver1" }
        it { expect(conf["sites"]["test_site1"]["user"]).to eq "test_user1" }
        it { expect(conf["sites"]["test_site1"]["password"]).to eq "test_password1" }
        it { expect(conf["sites"]["test_site2"]["driver"]).to eq "test_driver2" }
        it { expect(conf["sites"]["test_site2"]["user"]).to eq "test_user2" }
        it { expect(conf["sites"]["test_site2"]["password"]).to eq "test_password2" }
      end

    end # git contest config site add test_site2

  end

  context "git contest config site rm" do
    before(:each) do
      # create config
      File.open "#{@temp_dir}/config.yml", "w" do |file|
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
EOF
      end
    end

    context "git contest config site rm test_site1 (input = yes)" do

      let(:fake_input) { ::StringIO.new("yes") }
      before { expect { call_main(["config", "site", "rm", "test_site1"], fake_input).run }.to output(/.*/).to_stdout }

      context "load config" do
        let(:conf) { YAML.load_file "#{@temp_dir}/config.yml" }
        it { expect(conf["sites"]["test_site1"]).to be_nil }
        it { expect(conf["sites"]["test_site2"]["driver"]).to eq "test_driver2" }
        it { expect(conf["sites"]["test_site2"]["user"]).to eq "test_user2" }
        it { expect(conf["sites"]["test_site2"]["password"]).to eq "test_password2" }
      end

    end # git contest config site rm

    context "git contest config site rm test_site1 (input no)" do

      let(:fake_input) { ::StringIO.new("no") }
      before { expect { call_main(["config", "site", "rm", "test_site1"], fake_input).run }.to output(/.*/).to_stdout }

      context "load config" do
        let(:conf) { YAML.load_file "#{@temp_dir}/config.yml" }
        it { expect(conf["sites"]["test_site1"]["driver"]).to eq "test_driver1" }
        it { expect(conf["sites"]["test_site1"]["user"]).to eq "test_user1" }
        it { expect(conf["sites"]["test_site1"]["password"]).to eq "test_password1" }
        it { expect(conf["sites"]["test_site2"]["driver"]).to eq "test_driver2" }
        it { expect(conf["sites"]["test_site2"]["user"]).to eq "test_user2" }
        it { expect(conf["sites"]["test_site2"]["password"]).to eq "test_password2" }
      end

    end # git contest config site rm

  end

end
