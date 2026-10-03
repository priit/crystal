require "../spec_helper"

describe User do
  it "uses the users table" do
    user = User.new
    user.class.table_name.should eq("users")
  end
end
