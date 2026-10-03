require "../spec_helper"

describe Profile do
  it "uses the profiles table" do
    profile = Profile.new
    profile.class.table_name.should eq("profiles")
  end
end
