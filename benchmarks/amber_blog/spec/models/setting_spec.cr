require "../spec_helper"

describe Setting do
  it "uses the settings table" do
    setting = Setting.new
    setting.class.table_name.should eq("settings")
  end
end
