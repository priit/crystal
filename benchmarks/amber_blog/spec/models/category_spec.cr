require "../spec_helper"

describe Category do
  it "uses the categories table" do
    category = Category.new
    category.class.table_name.should eq("categories")
  end
end
