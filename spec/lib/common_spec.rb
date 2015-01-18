require "spec_helper"

describe "Common" do
  
  describe "get_config" do

    let(:tmp_dir) { ::Dir.mktmpdir }

    before do
      $git_contest_config = File.join(tmp_dir, "config.yml")
    end

    after do
      ::FileUtils.rm_r tmp_dir
    end

    context "empty file" do
    
      before do
        ::FileUtils.touch $git_contest_config
      end

      example do
        expect do
          config = get_config
          config["sites"]["foo"] = "bar"
        end.to_not raise_error
      end

    end

    context "valid yaml" do
    
      before do
        ::File.write $git_contest_config, {
        }.to_yaml
      end

      example do
        expect do
          config = get_config
          config["sites"]["foo"] = "bar"
        end.to_not raise_error
      end

    end

  end

end
