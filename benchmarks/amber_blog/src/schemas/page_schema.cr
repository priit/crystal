# Schema for validating Page create/update parameters.
#
# Used by PageController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class PageSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :title, String, required: true
  field :slug, String, required: true
  field :body, String
  field :position, Int32
end
