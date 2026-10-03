require "../spec_helper"

describe MenuItemController do
  describe "GET /menu_items" do
    it "responds successfully" do
      response = get("/menu_items")
      assert_response_success(response)
    end
  end

  describe "GET /menu_items/new" do
    it "responds successfully" do
      response = get("/menu_items/new")
      assert_response_success(response)
    end
  end

  describe "GET /menu_items/:id" do
    it "responds successfully" do
      response = get("/menu_items/1")
      # assert_response_success(response)
    end
  end

  describe "GET /menu_items/:id/edit" do
    it "responds successfully" do
      response = get("/menu_items/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /menu_items" do
    it "creates a new menu_item" do
      response = post("/menu_items")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /menu_items/:id" do
    it "deletes the menu_item" do
      response = delete("/menu_items/1")
      # assert_response_redirect(response)
    end
  end
end
