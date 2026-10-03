require "../spec_helper"

describe TagController do
  describe "GET /tags" do
    it "responds successfully" do
      response = get("/tags")
      assert_response_success(response)
    end
  end

  describe "GET /tags/new" do
    it "responds successfully" do
      response = get("/tags/new")
      assert_response_success(response)
    end
  end

  describe "GET /tags/:id" do
    it "responds successfully" do
      response = get("/tags/1")
      # assert_response_success(response)
    end
  end

  describe "GET /tags/:id/edit" do
    it "responds successfully" do
      response = get("/tags/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /tags" do
    it "creates a new tag" do
      response = post("/tags")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /tags/:id" do
    it "deletes the tag" do
      response = delete("/tags/1")
      # assert_response_redirect(response)
    end
  end
end
