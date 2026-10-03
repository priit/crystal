require "../spec_helper"

describe PageController do
  describe "GET /pages" do
    it "responds successfully" do
      response = get("/pages")
      assert_response_success(response)
    end
  end

  describe "GET /pages/new" do
    it "responds successfully" do
      response = get("/pages/new")
      assert_response_success(response)
    end
  end

  describe "GET /pages/:id" do
    it "responds successfully" do
      response = get("/pages/1")
      # assert_response_success(response)
    end
  end

  describe "GET /pages/:id/edit" do
    it "responds successfully" do
      response = get("/pages/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /pages" do
    it "creates a new page" do
      response = post("/pages")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /pages/:id" do
    it "deletes the page" do
      response = delete("/pages/1")
      # assert_response_redirect(response)
    end
  end
end
