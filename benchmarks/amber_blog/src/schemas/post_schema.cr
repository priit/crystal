# Schema for validating Post create/update parameters.
#
# Used by PostController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class PostSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :user_id, Int64
  field :category_id, Int64
  field :title, String, required: true
  field :slug, String, required: true
  field :body, String, required: true
  field :published, Bool
  field :published_at, Time, format: "datetime"
end
