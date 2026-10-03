class SubscriberController < ApplicationController
  schema :create, SubscriberSchema
  schema :update, SubscriberSchema

  @subscribers = [] of Subscriber
  @subscriber = Subscriber.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @subscribers = Subscriber.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if subscriber = Subscriber.find(params[:id])
      @subscriber = subscriber
      render("show.ecr")
    else
      flash[:danger] = "Subscriber not found"
      redirect_to "/subscribers"
    end
  end

  def new : String
    @subscriber = Subscriber.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(SubscriberSchema)
    subscriber = Subscriber.new
    subscriber.email = schema.email.not_nil!
    subscriber.confirmed = schema.confirmed

    if subscriber.save
      flash[:success] = "Subscriber created successfully"
      redirect_to "/subscribers/#{subscriber.id}"
    else
      @subscriber = subscriber
      flash[:danger] = "Could not create Subscriber"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if subscriber = Subscriber.find(params[:id])
      @subscriber = subscriber
      render("edit.ecr")
    else
      flash[:danger] = "Subscriber not found"
      redirect_to "/subscribers"
    end
  end

  def update : Int32 | String
    if subscriber = Subscriber.find(params[:id])
      schema = validated_as(SubscriberSchema)
      subscriber.email = schema.email.not_nil!
      subscriber.confirmed = schema.confirmed

      if subscriber.save
        flash[:success] = "Subscriber updated successfully"
        redirect_to "/subscribers/#{subscriber.id}"
      else
        @subscriber = subscriber
        flash[:danger] = "Could not update Subscriber"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Subscriber not found"
      redirect_to "/subscribers"
    end
  end

  def destroy : Int32
    if subscriber = Subscriber.find(params[:id])
      subscriber.destroy
      flash[:success] = "Subscriber deleted successfully"
    else
      flash[:danger] = "Subscriber not found"
    end
    redirect_to "/subscribers"
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
      @subscriber = Subscriber.new
      context.content = render("new.ecr")
    when :update
      if subscriber = Subscriber.find(params[:id])
        @subscriber = subscriber
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Subscriber not found"
        redirect_to "/subscribers"
      end
    else
      super
    end
  end
end
