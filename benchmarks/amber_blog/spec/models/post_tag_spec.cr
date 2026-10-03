require "../spec_helper"

describe PostTag do
  it "uses the post_tags table" do
    post_tag = PostTag.new
    post_tag.class.table_name.should eq("post_tags")
  end
end
