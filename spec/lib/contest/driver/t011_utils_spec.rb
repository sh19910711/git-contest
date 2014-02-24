require "spec_helper"
require "contest/driver/common"

describe "T011: Common" do
  before do
    ENV['GIT_CONTEST_HOME'] = @temp_dir
    init
  end

  context "A001: Utils" do
    context "check_file_map" do
      it "test.cpp -> cpp11: normal" do
        ret = Contest::Driver::Utils.check_file_map "test.cpp", {
          "cpp" => "cpp11"
        }
        expect(ret).to eq true
      end
      it "test.cpp -> cpp11: no map" do
        ret = Contest::Driver::Utils.check_file_map "test.cpp", {
        }
        expect(ret).to eq false
      end
      it "test.cpp -> cpp11: map is nil" do
        ret = Contest::Driver::Utils.check_file_map "test.cpp", nil
        expect(ret).to eq false
      end
      it "test.cpp: no map" do
        ret = Contest::Driver::Utils.check_file_map "test.cpp", {
          "py" => "python2"
        }
        expect(ret).to eq false
      end
      it "test.py: python2" do
        ret = Contest::Driver::Utils.check_file_map "test.py", {
          "py" => "python2"
        }
        expect(ret).to eq true
      end
    end

    context "resolve_file_map" do
      it "cpp -> cpp11" do
        ret = Contest::Driver::Utils.resolve_file_map "test.cpp", {
          "cpp" => "cpp11"
        }
        expect(ret).to eq "cpp11"
      end
    end

    context "get_all_drivers" do
      before(:each) do
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
        Contest::Driver::Utils.load_plugins
        ret1 = Contest::Driver::Utils.get_all_drivers.map {|driver| driver[:class_name] }
        expect(ret1).to include :Test01Driver
        expect(ret1).to include :Test02Driver
      end
    end
  end
end

