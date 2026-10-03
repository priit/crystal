require "../spec_helper"

describe PostTagController do
  describe "GET /post_tags" do
    it "responds successfully" do
      response = get("/post_tags")
      assert_response_success(response)
    end
  end

  describe "GET /post_tags/new" do
    it "responds successfully" do
      response = get("/post_tags/new")
      assert_response_success(response)
    end
  end

  describe "GET /post_tags/:id" do
    it "responds successfully" do
      response = get("/post_tags/1")
      # assert_response_success(response)
    end
  end

  describe "GET /post_tags/:id/edit" do
    it "responds successfully" do
      response = get("/post_tags/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /post_tags" do
    it "creates a new post_tag" do
      response = post("/post_tags")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /post_tags/:id" do
    it "deletes the post_tag" do
      response = delete("/post_tags/1")
      # assert_response_redirect(response)
    end
  end
end
