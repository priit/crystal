# Schema for validating PostTag create/update parameters.
#
# Used by PostTagController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class PostTagSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :post_id, Int64
  field :tag_id, Int64
end
