require 'spec_helper'
require 'yaml'

describe "T013: git-contest-config" do
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

    it "git contest config set key value" do
      bin_exec "config set key1 value2"
      ret2 = YAML.load_file "#{@temp_dir}/config.yml"
      expect(ret2["key1"]).to eq "value2"
    end

    it "git contest config set key (input from pipe)" do
      bin_exec "config set key1", "value2"
      ret2 = YAML.load_file "#{@temp_dir}/config.yml"
      expect(ret2["key1"]).to eq "value2"
    end

    it "git contest config set sites.test_site1.driver test_driver2" do
      bin_exec "config set sites.test_site1.driver test_driver2"
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
      ret = bin_exec "config get key1"
      expect(ret.strip).to eq "value1"
    end

    it "git contest config get sites.test_site1.user" do
      ret = bin_exec "config get sites.test_site1.user"
      expect(ret.strip).to eq "test_user1"
    end

    it "return keys" do
      ret = bin_exec "config get sites.test_site1"
      expect(ret).to include "driver"
      expect(ret).to include "user"
      expect(ret).to include "password"
      expect(ret).not_to include "test_driver1"
      expect(ret).not_to include "test_user1"
      expect(ret).not_to include "test_password1"
    end

    it "raise error: not found" do
      ret = bin_exec("config get foo.bar")
      expect(ret).to include "ERROR"
    end
  end

end
