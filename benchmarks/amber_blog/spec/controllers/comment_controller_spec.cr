require "../spec_helper"

describe CommentController do
  describe "GET /comments" do
    it "responds successfully" do
      response = get("/comments")
      assert_response_success(response)
    end
  end

  describe "GET /comments/new" do
    it "responds successfully" do
      response = get("/comments/new")
      assert_response_success(response)
    end
  end

  describe "GET /comments/:id" do
    it "responds successfully" do
      response = get("/comments/1")
      # assert_response_success(response)
    end
  end

  describe "GET /comments/:id/edit" do
    it "responds successfully" do
      response = get("/comments/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /comments" do
    it "creates a new comment" do
      response = post("/comments")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /comments/:id" do
    it "deletes the comment" do
      response = delete("/comments/1")
      # assert_response_redirect(response)
    end
  end
end
