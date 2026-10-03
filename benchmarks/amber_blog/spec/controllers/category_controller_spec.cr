require "../spec_helper"

describe CategoryController do
  describe "GET /categories" do
    it "responds successfully" do
      response = get("/categories")
      assert_response_success(response)
    end
  end

  describe "GET /categories/new" do
    it "responds successfully" do
      response = get("/categories/new")
      assert_response_success(response)
    end
  end

  describe "GET /categories/:id" do
    it "responds successfully" do
      response = get("/categories/1")
      # assert_response_success(response)
    end
  end

  describe "GET /categories/:id/edit" do
    it "responds successfully" do
      response = get("/categories/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /categories" do
    it "creates a new category" do
      response = post("/categories")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /categories/:id" do
    it "deletes the category" do
      response = delete("/categories/1")
      # assert_response_redirect(response)
    end
  end
end
