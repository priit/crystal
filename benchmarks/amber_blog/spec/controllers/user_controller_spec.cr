require "../spec_helper"

describe UserController do
  describe "GET /users" do
    it "responds successfully" do
      response = get("/users")
      assert_response_success(response)
    end
  end

  describe "GET /users/new" do
    it "responds successfully" do
      response = get("/users/new")
      assert_response_success(response)
    end
  end

  describe "GET /users/:id" do
    it "responds successfully" do
      response = get("/users/1")
      # assert_response_success(response)
    end
  end

  describe "GET /users/:id/edit" do
    it "responds successfully" do
      response = get("/users/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /users" do
    it "creates a new user" do
      response = post("/users")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /users/:id" do
    it "deletes the user" do
      response = delete("/users/1")
      # assert_response_redirect(response)
    end
  end
end
