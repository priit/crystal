Amber::Server.configure do
  pipeline :web do
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
    plug Amber::Pipe::Session.new
    plug Amber::Pipe::Flash.new
    plug Amber::Pipe::CSRF.new
  end

  pipeline :static do
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Static.new("./public")
  end

  pipeline :api do
    plug Amber::Pipe::Error.new
    plug Amber::Pipe::Logger.new
  end

  routes :web do
    resources "/menu_items", MenuItemController
    resources "/settings", SettingController
    resources "/subscribers", SubscriberController
    resources "/medias", MediaController
    resources "/pages", PageController
    resources "/comments", CommentController
    resources "/post_tags", PostTagController
    resources "/posts", PostController
    resources "/tags", TagController
    resources "/categories", CategoryController
    resources "/profiles", ProfileController
    resources "/users", UserController
    get "/", HomeController, :index
  end

  routes :static do
    get "/*", Amber::Controller::Static, :index
  end

  # routes :api do
  # end
end
