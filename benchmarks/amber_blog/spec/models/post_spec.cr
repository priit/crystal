require "../spec_helper"

describe Post do
  it "uses the posts table" do
    post = Post.new
    post.class.table_name.should eq("posts")
  end
end
