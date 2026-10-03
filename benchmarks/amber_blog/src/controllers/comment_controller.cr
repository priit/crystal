class CommentController < ApplicationController
  schema :create, CommentSchema
  schema :update, CommentSchema

  @comments = [] of Comment
  @comment = Comment.new
  @errors = [] of Amber::Schema::Error

  def index : String
    @comments = Comment.all.to_a
    render("index.ecr")
  end

  def show : Int32 | String
    if comment = Comment.find(params[:id])
      @comment = comment
      render("show.ecr")
    else
      flash[:danger] = "Comment not found"
      redirect_to "/comments"
    end
  end

  def new : String
    @comment = Comment.new
    render("new.ecr")
  end

  def create : Int32 | String
    schema = validated_as(CommentSchema)
    comment = Comment.new
    comment.post_id = schema.post_id
    comment.user_id = schema.user_id
    comment.body = schema.body.not_nil!
    comment.approved = schema.approved

    if comment.save
      flash[:success] = "Comment created successfully"
      redirect_to "/comments/#{comment.id}"
    else
      @comment = comment
      flash[:danger] = "Could not create Comment"
      render("new.ecr")
    end
  end

  def edit : Int32 | String
    if comment = Comment.find(params[:id])
      @comment = comment
      render("edit.ecr")
    else
      flash[:danger] = "Comment not found"
      redirect_to "/comments"
    end
  end

  def update : Int32 | String
    if comment = Comment.find(params[:id])
      schema = validated_as(CommentSchema)
      comment.post_id = schema.post_id
      comment.user_id = schema.user_id
      comment.body = schema.body.not_nil!
      comment.approved = schema.approved

      if comment.save
        flash[:success] = "Comment updated successfully"
        redirect_to "/comments/#{comment.id}"
      else
        @comment = comment
        flash[:danger] = "Could not update Comment"
        render("edit.ecr")
      end
    else
      flash[:danger] = "Comment not found"
      redirect_to "/comments"
    end
  end

  def destroy : Int32
    if comment = Comment.find(params[:id])
      comment.destroy
      flash[:success] = "Comment deleted successfully"
    else
      flash[:danger] = "Comment not found"
    end
    redirect_to "/comments"
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
      @comment = Comment.new
      context.content = render("new.ecr")
    when :update
      if comment = Comment.find(params[:id])
        @comment = comment
        context.content = render("edit.ecr")
      else
        flash[:danger] = "Comment not found"
        redirect_to "/comments"
      end
    else
      super
    end
  end
end
