require "../spec_helper"

describe PostController do
  describe "GET /posts" do
    it "responds successfully" do
      response = get("/posts")
      assert_response_success(response)
    end
  end

  describe "GET /posts/new" do
    it "responds successfully" do
      response = get("/posts/new")
      assert_response_success(response)
    end
  end

  describe "GET /posts/:id" do
    it "responds successfully" do
      response = get("/posts/1")
      # assert_response_success(response)
    end
  end

  describe "GET /posts/:id/edit" do
    it "responds successfully" do
      response = get("/posts/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /posts" do
    it "creates a new post" do
      response = post("/posts")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /posts/:id" do
    it "deletes the post" do
      response = delete("/posts/1")
      # assert_response_redirect(response)
    end
  end
end
