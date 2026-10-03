class PageController < ApplicationController
  schema :create, PageSchema
  schema :update, PageSchema

  @pages = [] of Page
  @page = Page.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @pages = Page.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if page = Page.find(params[:id])
      @page = page
      render("show.ecr")
    else
      flash[:danger] = "Page not found"
      redirect_to "/pages"
    end
  end

  def new : String
    @page = Page.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(PageSchema)
    page = Page.new
    page.title = schema.title.not_nil!
    page.slug = schema.slug.not_nil!
    page.body = schema.body
    page.position = schema.position

    if page.save
      flash[:success] = "Page created successfully"
      redirect_to "/pages/#{page.id}"
    else
      @page = page
      flash[:danger] = "Could not create Page"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if page = Page.find(params[:id])
      @page = page
      render("edit.ecr")
    else
      flash[:danger] = "Page not found"
      redirect_to "/pages"
    end
  end

  def update : Int32 | String
    if page = Page.find(params[:id])
      schema = validated_as(PageSchema)
      page.title = schema.title.not_nil!
      page.slug = schema.slug.not_nil!
      page.body = schema.body
      page.position = schema.position

      if page.save
        flash[:success] = "Page updated successfully"
        redirect_to "/pages/#{page.id}"
      else
        @page = page
        flash[:danger] = "Could not update Page"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Page not found"
      redirect_to "/pages"
    end
  end

  def destroy : Int32
    if page = Page.find(params[:id])
      page.destroy
      flash[:success] = "Page deleted successfully"
    else
      flash[:danger] = "Page not found"
    end
    redirect_to "/pages"
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
      @page = Page.new
      context.content = render("new.ecr")
    when :update
      if page = Page.find(params[:id])
        @page = page
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Page not found"
        redirect_to "/pages"
      end
    else
      super
    end
  end
end
