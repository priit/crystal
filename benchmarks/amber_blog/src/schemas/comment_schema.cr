# Schema for validating Comment create/update parameters.
#
# Used by CommentController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class CommentSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :post_id, Int64
  field :user_id, Int64
  field :body, String, required: true
  field :approved, Bool
end
