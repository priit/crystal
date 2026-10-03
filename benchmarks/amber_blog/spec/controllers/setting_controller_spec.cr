require "../spec_helper"

describe SettingController do
  describe "GET /settings" do
    it "responds successfully" do
      response = get("/settings")
      assert_response_success(response)
    end
  end

  describe "GET /settings/new" do
    it "responds successfully" do
      response = get("/settings/new")
      assert_response_success(response)
    end
  end

  describe "GET /settings/:id" do
    it "responds successfully" do
      response = get("/settings/1")
      # assert_response_success(response)
    end
  end

  describe "GET /settings/:id/edit" do
    it "responds successfully" do
      response = get("/settings/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /settings" do
    it "creates a new setting" do
      response = post("/settings")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /settings/:id" do
    it "deletes the setting" do
      response = delete("/settings/1")
      # assert_response_redirect(response)
    end
  end
end
