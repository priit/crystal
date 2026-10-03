class ProfileController < ApplicationController
  schema :create, ProfileSchema
  schema :update, ProfileSchema

  @profiles = [] of Profile
  @profile = Profile.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @profiles = Profile.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if profile = Profile.find(params[:id])
      @profile = profile
      render("show.ecr")
    else
      flash[:danger] = "Profile not found"
      redirect_to "/profiles"
    end
  end

  def new : String
    @profile = Profile.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(ProfileSchema)
    profile = Profile.new
    profile.user_id = schema.user_id
    profile.website = schema.website
    profile.location = schema.location
    profile.avatar_url = schema.avatar_url

    if profile.save
      flash[:success] = "Profile created successfully"
      redirect_to "/profiles/#{profile.id}"
    else
      @profile = profile
      flash[:danger] = "Could not create Profile"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if profile = Profile.find(params[:id])
      @profile = profile
      render("edit.ecr")
    else
      flash[:danger] = "Profile not found"
      redirect_to "/profiles"
    end
  end

  def update : Int32 | String
    if profile = Profile.find(params[:id])
      schema = validated_as(ProfileSchema)
      profile.user_id = schema.user_id
      profile.website = schema.website
      profile.location = schema.location
      profile.avatar_url = schema.avatar_url

      if profile.save
        flash[:success] = "Profile updated successfully"
        redirect_to "/profiles/#{profile.id}"
      else
        @profile = profile
        flash[:danger] = "Could not update Profile"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Profile not found"
      redirect_to "/profiles"
    end
  end

  def destroy : Int32
    if profile = Profile.find(params[:id])
      profile.destroy
      flash[:success] = "Profile deleted successfully"
    else
      flash[:danger] = "Profile not found"
    end
    redirect_to "/profiles"
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
      @profile = Profile.new
      context.content = render("new.ecr")
    when :update
      if profile = Profile.find(params[:id])
        @profile = profile
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Profile not found"
        redirect_to "/profiles"
      end
    else
      super
    end
  end
end
