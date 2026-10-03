class TagController < ApplicationController
  schema :create, TagSchema
  schema :update, TagSchema

  @tags = [] of Tag
  @tag = Tag.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @tags = Tag.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if tag = Tag.find(params[:id])
      @tag = tag
      render("show.ecr")
    else
      flash[:danger] = "Tag not found"
      redirect_to "/tags"
    end
  end

  def new : String
    @tag = Tag.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(TagSchema)
    tag = Tag.new
    tag.name = schema.name.not_nil!
    tag.slug = schema.slug.not_nil!

    if tag.save
      flash[:success] = "Tag created successfully"
      redirect_to "/tags/#{tag.id}"
    else
      @tag = tag
      flash[:danger] = "Could not create Tag"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if tag = Tag.find(params[:id])
      @tag = tag
      render("edit.ecr")
    else
      flash[:danger] = "Tag not found"
      redirect_to "/tags"
    end
  end

  def update : Int32 | String
    if tag = Tag.find(params[:id])
      schema = validated_as(TagSchema)
      tag.name = schema.name.not_nil!
      tag.slug = schema.slug.not_nil!

      if tag.save
        flash[:success] = "Tag updated successfully"
        redirect_to "/tags/#{tag.id}"
      else
        @tag = tag
        flash[:danger] = "Could not update Tag"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Tag not found"
      redirect_to "/tags"
    end
  end

  def destroy : Int32
    if tag = Tag.find(params[:id])
      tag.destroy
      flash[:success] = "Tag deleted successfully"
    else
      flash[:danger] = "Tag not found"
    end
    redirect_to "/tags"
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
      @tag = Tag.new
      context.content = render("new.ecr")
    when :update
      if tag = Tag.find(params[:id])
        @tag = tag
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Tag not found"
        redirect_to "/tags"
      end
    else
      super
    end
  end
end
