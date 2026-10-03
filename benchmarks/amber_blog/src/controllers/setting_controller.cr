class SettingController < ApplicationController
  schema :create, SettingSchema
  schema :update, SettingSchema

  @settings = [] of Setting
  @setting = Setting.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @settings = Setting.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if setting = Setting.find(params[:id])
      @setting = setting
      render("show.ecr")
    else
      flash[:danger] = "Setting not found"
      redirect_to "/settings"
    end
  end

  def new : String
    @setting = Setting.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(SettingSchema)
    setting = Setting.new
    setting.key = schema.key.not_nil!
    setting.value = schema.value

    if setting.save
      flash[:success] = "Setting created successfully"
      redirect_to "/settings/#{setting.id}"
    else
      @setting = setting
      flash[:danger] = "Could not create Setting"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if setting = Setting.find(params[:id])
      @setting = setting
      render("edit.ecr")
    else
      flash[:danger] = "Setting not found"
      redirect_to "/settings"
    end
  end

  def update : Int32 | String
    if setting = Setting.find(params[:id])
      schema = validated_as(SettingSchema)
      setting.key = schema.key.not_nil!
      setting.value = schema.value

      if setting.save
        flash[:success] = "Setting updated successfully"
        redirect_to "/settings/#{setting.id}"
      else
        @setting = setting
        flash[:danger] = "Could not update Setting"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Setting not found"
      redirect_to "/settings"
    end
  end

  def destroy : Int32
    if setting = Setting.find(params[:id])
      setting.destroy
      flash[:success] = "Setting deleted successfully"
    else
      flash[:danger] = "Setting not found"
    end
    redirect_to "/settings"
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
      @setting = Setting.new
      context.content = render("new.ecr")
    when :update
      if setting = Setting.find(params[:id])
        @setting = setting
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Setting not found"
        redirect_to "/settings"
      end
    else
      super
    end
  end
end
