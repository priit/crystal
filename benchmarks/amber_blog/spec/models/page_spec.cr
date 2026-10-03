require "../spec_helper"

describe Page do
  it "uses the pages table" do
    page = Page.new
    page.class.table_name.should eq("pages")
  end
end
