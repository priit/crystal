require "../spec_helper"

describe ProfileController do
  describe "GET /profiles" do
    it "responds successfully" do
      response = get("/profiles")
      assert_response_success(response)
    end
  end

  describe "GET /profiles/new" do
    it "responds successfully" do
      response = get("/profiles/new")
      assert_response_success(response)
    end
  end

  describe "GET /profiles/:id" do
    it "responds successfully" do
      response = get("/profiles/1")
      # assert_response_success(response)
    end
  end

  describe "GET /profiles/:id/edit" do
    it "responds successfully" do
      response = get("/profiles/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /profiles" do
    it "creates a new profile" do
      response = post("/profiles")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /profiles/:id" do
    it "deletes the profile" do
      response = delete("/profiles/1")
      # assert_response_redirect(response)
    end
  end
end
