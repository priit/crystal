class CategoryController < ApplicationController
  schema :create, CategorySchema
  schema :update, CategorySchema

  @categories = [] of Category
  @category = Category.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @categories = Category.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if category = Category.find(params[:id])
      @category = category
      render("show.ecr")
    else
      flash[:danger] = "Category not found"
      redirect_to "/categories"
    end
  end

  def new : String
    @category = Category.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(CategorySchema)
    category = Category.new
    category.name = schema.name.not_nil!
    category.slug = schema.slug.not_nil!
    category.description = schema.description

    if category.save
      flash[:success] = "Category created successfully"
      redirect_to "/categories/#{category.id}"
    else
      @category = category
      flash[:danger] = "Could not create Category"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if category = Category.find(params[:id])
      @category = category
      render("edit.ecr")
    else
      flash[:danger] = "Category not found"
      redirect_to "/categories"
    end
  end

  def update : Int32 | String
    if category = Category.find(params[:id])
      schema = validated_as(CategorySchema)
      category.name = schema.name.not_nil!
      category.slug = schema.slug.not_nil!
      category.description = schema.description

      if category.save
        flash[:success] = "Category updated successfully"
        redirect_to "/categories/#{category.id}"
      else
        @category = category
        flash[:danger] = "Could not update Category"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Category not found"
      redirect_to "/categories"
    end
  end

  def destroy : Int32
    if category = Category.find(params[:id])
      category.destroy
      flash[:success] = "Category deleted successfully"
    else
      flash[:danger] = "Category not found"
    end
    redirect_to "/categories"
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
      @category = Category.new
      context.content = render("new.ecr")
    when :update
      if category = Category.find(params[:id])
        @category = category
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Category not found"
        redirect_to "/categories"
      end
    else
      super
    end
  end
end
