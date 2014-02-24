require 'spec_helper'

describe "T012: git-contest-list" do
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

    it "should include site name" do
      ret = bin_exec "list sites"
      (1..3).each {|x| expect(ret).to include "test_site#{x}" }
    end

    it "should include user name" do
      ret = bin_exec "list sites"
      (1..3).each {|x| expect(ret).to include "test_user#{x}" }
    end

    it "should include driver name" do
      ret = bin_exec "list sites"
      (1..3).each {|x| expect(ret).to include "test_driver#{x}" }
    end

    it "should NOT include password" do
      ret = bin_exec "list sites"
      (1..3).each {|x| expect(ret).not_to include "test_password#{x}" }
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

    it "contains plugins" do
      ret = bin_exec "list drivers"
      expect(ret).to include "Test01Driver"
      expect(ret).to include "test01_desc"
      expect(ret).to include "Test02Driver"
      expect(ret).to include "test02_desc"
    end
  end

end
