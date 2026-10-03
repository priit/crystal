require "../spec_helper"

describe Comment do
  it "uses the comments table" do
    comment = Comment.new
    comment.class.table_name.should eq("comments")
  end
end
