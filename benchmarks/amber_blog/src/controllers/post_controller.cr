class PostController < ApplicationController
  schema :create, PostSchema
  schema :update, PostSchema

  @posts = [] of Post
  @post = Post.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @posts = Post.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if post = Post.find(params[:id])
      @post = post
      render("show.ecr")
    else
      flash[:danger] = "Post not found"
      redirect_to "/posts"
    end
  end

  def new : String
    @post = Post.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(PostSchema)
    post = Post.new
    post.user_id = schema.user_id
    post.category_id = schema.category_id
    post.title = schema.title.not_nil!
    post.slug = schema.slug.not_nil!
    post.body = schema.body.not_nil!
    post.published = schema.published
    post.published_at = schema.published_at

    if post.save
      flash[:success] = "Post created successfully"
      redirect_to "/posts/#{post.id}"
    else
      @post = post
      flash[:danger] = "Could not create Post"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if post = Post.find(params[:id])
      @post = post
      render("edit.ecr")
    else
      flash[:danger] = "Post not found"
      redirect_to "/posts"
    end
  end

  def update : Int32 | String
    if post = Post.find(params[:id])
      schema = validated_as(PostSchema)
      post.user_id = schema.user_id
      post.category_id = schema.category_id
      post.title = schema.title.not_nil!
      post.slug = schema.slug.not_nil!
      post.body = schema.body.not_nil!
      post.published = schema.published
      post.published_at = schema.published_at

      if post.save
        flash[:success] = "Post updated successfully"
        redirect_to "/posts/#{post.id}"
      else
        @post = post
        flash[:danger] = "Could not update Post"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Post not found"
      redirect_to "/posts"
    end
  end

  def destroy : Int32
    if post = Post.find(params[:id])
      post.destroy
      flash[:success] = "Post deleted successfully"
    else
      flash[:danger] = "Post not found"
    end
    redirect_to "/posts"
  end

  protected def handle_schema_validation_failure(
    action : Symbol,
    result : Amber::Schema::LegacyResult,
  ) : Nil
    @errors = result.errors
    error = result.errors.first?
    response.status_code = error.is_a?(Amber::Schema::RequestParseError) ? error.http_status : 422
    response.content_type = "text/html"
    flash[:danger] = "Validation failed"

    case action
    when :create
      @post = Post.new
      context.content = render("new.ecr")
    when :update
      if post = Post.find(params[:id])
        @post = post
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Post not found"
        redirect_to "/posts"
      end
    else
      super
    end
  end
end
