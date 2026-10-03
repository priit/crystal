require "../spec_helper"

describe MediaController do
  describe "GET /medias" do
    it "responds successfully" do
      response = get("/medias")
      assert_response_success(response)
    end
  end

  describe "GET /medias/new" do
    it "responds successfully" do
      response = get("/medias/new")
      assert_response_success(response)
    end
  end

  describe "GET /medias/:id" do
    it "responds successfully" do
      response = get("/medias/1")
      # assert_response_success(response)
    end
  end

  describe "GET /medias/:id/edit" do
    it "responds successfully" do
      response = get("/medias/1/edit")
      # assert_response_success(response)
    end
  end

  describe "POST /medias" do
    it "creates a new media" do
      response = post("/medias")
      # assert_response_redirect(response)
    end
  end

  describe "DELETE /medias/:id" do
    it "deletes the media" do
      response = delete("/medias/1")
      # assert_response_redirect(response)
    end
  end
end
