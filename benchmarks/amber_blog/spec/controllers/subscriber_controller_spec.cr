require "../spec_helper"

describe SubscriberController do
  describe "GET /subscribers" do
    it "responds successfully" do
      response = get("/subscribers")
      assert_response_success(response)
    end
  end

  describe "GET /subscribers/new" do
    it "responds successfully" do
      response = get("/subscribers/new")
      assert_response_success(response)
    end
  end

  describe "GET /subscribers/:id" do
    it "responds successfully" do
      response = get("/subscribers/1")
      # assert_response_success(response)
    end
  end

  describe "GET /subscribers/:id/edit" do
    it "responds successfully" do
      response = get("/subscribers/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /subscribers" do
    it "creates a new subscriber" do
      response = post("/subscribers")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /subscribers/:id" do
    it "deletes the subscriber" do
      response = delete("/subscribers/1")
      # assert_response_redirect(response)
    end
  end
end
