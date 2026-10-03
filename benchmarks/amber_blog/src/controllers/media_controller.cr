class MediaController < ApplicationController
  schema :create, MediaSchema
  schema :update, MediaSchema

  @medias = [] of Media
  @media = Media.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @medias = Media.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if media = Media.find(params[:id])
      @media = media
      render("show.ecr")
    else
      flash[:danger] = "Media not found"
      redirect_to "/medias"
    end
  end

  def new : String
    @media = Media.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(MediaSchema)
    media = Media.new
    media.user_id = schema.user_id
    media.filename = schema.filename.not_nil!
    media.content_type = schema.content_type
    media.byte_size = schema.byte_size

    if media.save
      flash[:success] = "Media created successfully"
      redirect_to "/medias/#{media.id}"
    else
      @media = media
      flash[:danger] = "Could not create Media"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if media = Media.find(params[:id])
      @media = media
      render("edit.ecr")
    else
      flash[:danger] = "Media not found"
      redirect_to "/medias"
    end
  end

  def update : Int32 | String
    if media = Media.find(params[:id])
      schema = validated_as(MediaSchema)
      media.user_id = schema.user_id
      media.filename = schema.filename.not_nil!
      media.content_type = schema.content_type
      media.byte_size = schema.byte_size

      if media.save
        flash[:success] = "Media updated successfully"
        redirect_to "/medias/#{media.id}"
      else
        @media = media
        flash[:danger] = "Could not update Media"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Media not found"
      redirect_to "/medias"
    end
  end

  def destroy : Int32
    if media = Media.find(params[:id])
      media.destroy
      flash[:success] = "Media deleted successfully"
    else
      flash[:danger] = "Media not found"
    end
    redirect_to "/medias"
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
      @media = Media.new
      context.content = render("new.ecr")
    when :update
      if media = Media.find(params[:id])
        @media = media
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Media not found"
        redirect_to "/medias"
      end
    else
      super
    end
  end
end
