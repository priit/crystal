require "../spec_helper"

describe Media do
  it "uses the medias table" do
    media = Media.new
    media.class.table_name.should eq("medias")
  end
end
