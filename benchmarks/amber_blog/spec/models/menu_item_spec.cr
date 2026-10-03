require "../spec_helper"

describe MenuItem do
  it "uses the menu_items table" do
    menu_item = MenuItem.new
    menu_item.class.table_name.should eq("menu_items")
  end
end
