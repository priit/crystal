class UserController < ApplicationController
  schema :create, UserSchema
  schema :update, UserSchema

  @users = [] of User
  @user = User.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @users = User.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if user = User.find(params[:id])
      @user = user
      render("show.ecr")
    else
      flash[:danger] = "User not found"
      redirect_to "/users"
    end
  end

  def new : String
    @user = User.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(UserSchema)
    user = User.new
    user.name = schema.name.not_nil!
    user.email = schema.email.not_nil!
    user.bio = schema.bio
    user.admin = schema.admin

    if user.save
      flash[:success] = "User created successfully"
      redirect_to "/users/#{user.id}"
    else
      @user = user
      flash[:danger] = "Could not create User"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if user = User.find(params[:id])
      @user = user
      render("edit.ecr")
    else
      flash[:danger] = "User not found"
      redirect_to "/users"
    end
  end

  def update : Int32 | String
    if user = User.find(params[:id])
      schema = validated_as(UserSchema)
      user.name = schema.name.not_nil!
      user.email = schema.email.not_nil!
      user.bio = schema.bio
      user.admin = schema.admin

      if user.save
        flash[:success] = "User updated successfully"
        redirect_to "/users/#{user.id}"
      else
        @user = user
        flash[:danger] = "Could not update User"
        render("edit.ecr")
      end
    else
      flash[:danger] = "User not found"
      redirect_to "/users"
    end
  end

  def destroy : Int32
    if user = User.find(params[:id])
      user.destroy
      flash[:success] = "User deleted successfully"
    else
      flash[:danger] = "User not found"
    end
    redirect_to "/users"
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
      @user = User.new
      context.content = render("new.ecr")
    when :update
      if user = User.find(params[:id])
        @user = user
        context.content = render("edit.ecr")
      else
        flash[:danger] = "User not found"
        redirect_to "/users"
      end
    else
      super
    end
  end
end
