require "spec_helper"
require "contest/driver/common"

describe "T011: Common" do
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
  end
end

