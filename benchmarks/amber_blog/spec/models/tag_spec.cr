require "../spec_helper"

describe Tag do
  it "uses the tags table" do
    tag = Tag.new
    tag.class.table_name.should eq("tags")
  end
end
