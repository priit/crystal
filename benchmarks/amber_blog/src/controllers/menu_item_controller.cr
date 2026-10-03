class MenuItemController < ApplicationController
  schema :create, MenuItemSchema
  schema :update, MenuItemSchema

  @menu_items = [] of MenuItem
  @menu_item = MenuItem.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @menu_items = MenuItem.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if menu_item = MenuItem.find(params[:id])
      @menu_item = menu_item
      render("show.ecr")
    else
      flash[:danger] = "MenuItem not found"
      redirect_to "/menu_items"
    end
  end

  def new : String
    @menu_item = MenuItem.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(MenuItemSchema)
    menu_item = MenuItem.new
    menu_item.page_id = schema.page_id
    menu_item.label = schema.label.not_nil!
    menu_item.url = schema.url
    menu_item.position = schema.position

    if menu_item.save
      flash[:success] = "MenuItem created successfully"
      redirect_to "/menu_items/#{menu_item.id}"
    else
      @menu_item = menu_item
      flash[:danger] = "Could not create MenuItem"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if menu_item = MenuItem.find(params[:id])
      @menu_item = menu_item
      render("edit.ecr")
    else
      flash[:danger] = "MenuItem not found"
      redirect_to "/menu_items"
    end
  end

  def update : Int32 | String
    if menu_item = MenuItem.find(params[:id])
      schema = validated_as(MenuItemSchema)
      menu_item.page_id = schema.page_id
      menu_item.label = schema.label.not_nil!
      menu_item.url = schema.url
      menu_item.position = schema.position

      if menu_item.save
        flash[:success] = "MenuItem updated successfully"
        redirect_to "/menu_items/#{menu_item.id}"
      else
        @menu_item = menu_item
        flash[:danger] = "Could not update MenuItem"
        render("edit.ecr")
      end
    else
      flash[:danger] = "MenuItem not found"
      redirect_to "/menu_items"
    end
  end

  def destroy : Int32
    if menu_item = MenuItem.find(params[:id])
      menu_item.destroy
      flash[:success] = "MenuItem deleted successfully"
    else
      flash[:danger] = "MenuItem not found"
    end
    redirect_to "/menu_items"
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
      @menu_item = MenuItem.new
      context.content = render("new.ecr")
    when :update
      if menu_item = MenuItem.find(params[:id])
        @menu_item = menu_item
        context.content = render("edit.ecr")
      else
        flash[:danger] = "MenuItem not found"
        redirect_to "/menu_items"
      end
    else
      super
    end
  end
end
