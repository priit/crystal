# Schema for validating Tag create/update parameters.
#
# Used by TagController for request validation.
#
# See: https://amberframework.org/docs/v2/guides/schema-api/
class TagSchema < Amber::Schema::Definition
  content_type "application/x-www-form-urlencoded"

  field :name, String, required: true
  field :slug, String, required: true
end
