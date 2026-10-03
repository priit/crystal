class PostTagController < ApplicationController
  schema :create, PostTagSchema
  schema :update, PostTagSchema

  @post_tags = [] of PostTag
  @post_tag = PostTag.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @post_tags = PostTag.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if post_tag = PostTag.find(params[:id])
      @post_tag = post_tag
      render("show.ecr")
    else
      flash[:danger] = "PostTag not found"
      redirect_to "/post_tags"
    end
  end

  def new : String
    @post_tag = PostTag.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(PostTagSchema)
    post_tag = PostTag.new
    post_tag.post_id = schema.post_id
    post_tag.tag_id = schema.tag_id

    if post_tag.save
      flash[:success] = "PostTag created successfully"
      redirect_to "/post_tags/#{post_tag.id}"
    else
      @post_tag = post_tag
      flash[:danger] = "Could not create PostTag"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if post_tag = PostTag.find(params[:id])
      @post_tag = post_tag
      render("edit.ecr")
    else
      flash[:danger] = "PostTag not found"
      redirect_to "/post_tags"
    end
  end

  def update : Int32 | String
    if post_tag = PostTag.find(params[:id])
      schema = validated_as(PostTagSchema)
      post_tag.post_id = schema.post_id
      post_tag.tag_id = schema.tag_id

      if post_tag.save
        flash[:success] = "PostTag updated successfully"
        redirect_to "/post_tags/#{post_tag.id}"
      else
        @post_tag = post_tag
        flash[:danger] = "Could not update PostTag"
        render("edit.ecr")
      end
    else
      flash[:danger] = "PostTag not found"
      redirect_to "/post_tags"
    end
  end

  def destroy : Int32
    if post_tag = PostTag.find(params[:id])
      post_tag.destroy
      flash[:success] = "PostTag deleted successfully"
    else
      flash[:danger] = "PostTag not found"
    end
    redirect_to "/post_tags"
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
      @post_tag = PostTag.new
      context.content = render("new.ecr")
    when :update
      if post_tag = PostTag.find(params[:id])
        @post_tag = post_tag
        context.content = render("edit.ecr")
      else
        flash[:danger] = "PostTag not found"
        redirect_to "/post_tags"
      end
    else
      super
    end
  end
end
