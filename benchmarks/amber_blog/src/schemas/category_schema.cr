# Schema for validating Category create/update parameters.
#
# Used by CategoryController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class CategorySchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :name, String, required: true
  field :slug, String, required: true
  field :description, String
end
