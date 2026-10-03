require "../spec_helper"

describe Subscriber do
  it "uses the subscribers table" do
    subscriber = Subscriber.new
    subscriber.class.table_name.should eq("subscribers")
  end
end
